
#####################
# Step 1: Install devtools
#####################
install.packages("devtools")

devtools::install_github("abresler/nbastatR")
#####################
# Step 2: Install packages
#####################
install.packages("tidyverse")
install.packages("nbastatR")
install.packages("BasketballAnalyzeR")
install.packages("jsonlite")
install.packages("janitor")
install.packages("extrafont")
install.packages("ggrepel")
install.packages("scales")
install.packages("teamcolors")
install.packages("zoo")
install.packages("future")
install.packages("lubridate")

#####################
# Step 3: Load libraries
#####################
library(tidyverse)
library(nbastatR)
library(BasketballAnalyzeR)
library(jsonlite)
library(janitor)
library(extrafont)
library(ggrepel)
library(scales)
library(teamcolors)
library(zoo)
library(future)
library(lubridate)
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

#####################
## Get game IDs
#####################
# Select seasons from 1949 and after (Select 20 century)
selectedSeasons <- c(2000:2010)
# Get game IDs for Regular Season and Playoffs
gameIds_Reg <- suppressWarnings(seasons_schedule(seasons = selectedSeasons, season_types = "Regular Season") %>% select(idGame, slugMatchup))
gameIds_PO <- suppressWarnings(seasons_schedule(seasons = selectedSeasons, season_types = "Playoffs") %>% select(idGame, slugMatchup))
## rbind function is concat on row
gameIds_all <- rbind(gameIds_Reg, gameIds_PO)

# Peek at the game IDs
head(gameIds_all)
tail(gameIds_all)

#####################
## Retrieve gamelog data for players and teams
#####################
# Get player gamelogs
P_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "player", season_types = "Regular Season"))
P_gamelog_po <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "player", season_types = "Playoffs"))
## rbind function is concat on row
#binds two data sets
#rbind(BOD,BOD) 
#we can combine row if data not same number = bind_row()
P_gamelog_all <- rbind(P_gamelog_reg, P_gamelog_po)
View(head(P_gamelog_all))

# Get team gamelogs
T_gamelog_reg <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "team", season_types = "Regular Season"))
T_gamelog_po <- suppressWarnings(game_logs(seasons = selectedSeasons, league = "NBA", result_types = "team", season_types = "Playoffs"))
T_gamelog_all <- rbind(T_gamelog_reg, T_gamelog_po)
View(head(T_gamelog_all))

########################################
### Create player and team boxscores
########################################
# Create Tbox (Team boxscore) per season
Tbox_all <- T_gamelog_all %>%
  group_by("Season"=yearSeason, "Team"=slugTeam) %>%
  summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="W"), L=sum(outcomeGame=="L"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()
# Create Obox (Opponent Team boxscore) per season
Obox_all <- T_gamelog_all %>%
  group_by("Season"=yearSeason, "Team"=slugOpponent) %>%
summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="L"), L=sum(outcomeGame=="W"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()
# Create Pbox (Player boxscore) per season
Pbox_all <- P_gamelog_all %>%
  group_by("Season"=yearSeason, "Team"=slugTeam, "Player"=namePlayer) %>%
summarise(GP=n(), MIN=sum(minutes), PTS=sum(pts),
                   P2M=sum(fg2m), P2A=sum(fg2a), P2p=100*P2M/P2A,
                   P3M=sum(fg3m), P3A=sum(fg3a), P3p=100*P3M/P3A,
                   FTM=sum(ftm), FTA=sum(fta), FTp=100*FTM/FTA,
                   OREB=sum(oreb), DREB=sum(dreb), AST=sum(ast),
                   TOV=sum(tov), STL=sum(stl), BLK=sum(blk),
                   PF=sum(pf)) %>%
  as.data.frame()

## look at how lakers good team on 20 century
View(Tbox_all[Tbox_all$Team=="LAL",]) ## "LAL",(is retrieve all)]
View(Obox_all[Obox_all$Team!="LAL",])
## look at the duo lakers
View(Pbox_all[Pbox_all$Player=="Kobe Bryant",])
View(Pbox_all[Pbox_all$Player=="Shaquille O'Neal",])


################################
## Use Regular Season data
##################################
# Create Tbox (Team boxscore) for each Regular Season
Tbox <- T_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugTeam) %>%
  summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="W"), L=sum(outcomeGame=="L"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()

# Create Obox (Opponent Team boxscore) for each Regular Season
Obox <- T_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugOpponent) %>%
  summarise(GP=n(), MIN=sum(round(minutesTeam/5)),
                   PTS=sum(ptsTeam),
                   W=sum(outcomeGame=="L"), L=sum(outcomeGame=="W"),
                   P2M=sum(fg2mTeam), P2A=sum(fg2aTeam), P2p=P2M/P2A,
                   P3M=sum(fg3mTeam), P3A=sum(fg3aTeam), P3p=P3M/P3A,
                   FTM=sum(ftmTeam), FTA=sum(ftaTeam), FTp=FTM/FTA,
                   OREB=sum(orebTeam), DREB=sum(drebTeam), AST=sum(astTeam),
                   TOV=sum(tovTeam), STL=sum(stlTeam), BLK=sum(blkTeam),
                   PF=sum(pfTeam), PM=sum(plusminusTeam)) %>%
  as.data.frame()

# Create Pbox (Player boxscore) for each Regular Season
Pbox <- P_gamelog_reg %>%
  group_by("Season"=yearSeason, "Team"=slugTeam, "Player"=namePlayer) %>%
  summarise(GP=n(), MIN=sum(minutes), PTS=sum(pts),
                   P2M=sum(fg2m), P2A=sum(fg2a), P2p=100*P2M/P2A,
                   P3M=sum(fg3m), P3A=sum(fg3a), P3p=100*P3M/P3A,
                   FTM=sum(ftm), FTA=sum(fta), FTp=100*FTM/FTA,
                   OREB=sum(oreb), DREB=sum(dreb), AST=sum(ast),
                   TOV=sum(tov), STL=sum(stl), BLK=sum(blk),
                   PF=sum(pf)) %>%
  as.data.frame()

View(Pbox[Pbox$Player=="Kobe Bryant",])
View(Pbox[Pbox$Player=="Shaquille O'Neal",])

#####################
# Bar plots
#####################
## use barline##
barline(
  data,
  id,
  bars,
  line,
  order.by = id,
  decreasing = TRUE,
  labels.bars = NULL,
  label.line = NULL,
  title = NULL
)
teamSelected <- "LAL"
Pbox.sel <- subset(Pbox, Team==teamSelected &
                     MIN>=1000)
seasonSelected <- 2001
plot1<-barline(data=Pbox.sel[Pbox.sel$Season==seasonSelected,], id="Player",
        bars=c("P2M","P3M","FTM"), line="PTS",
        order.by="PTS", labels.bars=c("2PM","3PM","FTM"),
        title=glue("{teamSelected} - 2000"))  

all_ms<- c("P2M","P3M","FTM")
ggplot(Pbox.sel[Pbox.sel$Season == seasonSelected, ], aes(x = Player, y = PTS))+
  geom_bar(aes(fill = all_ms), stat = "identity", order = "PTS")+  # Set fill color by factor(bars)
  geom_line(aes(y = PTS), color = "gold") +  # Set line color
  labs(title = glue("{teamSelected} - 2000"), x = "Player", y = "Points")+
  theme_minimal()  # Adjust theme as desired

#####################
# Scatter plots
#####################
teamSelected <- "LAL"
Pbox.sel <- subset(Pbox, Team==teamSelected & MIN>=1000)
attach(Pbox.sel)
X <- data.frame(AST, TOV, PTS)/MIN
detach(Pbox.sel)
mypal <- colorRampPalette(c("blue","yellow","red"))

plot2<-scatterplot(X, data.var=c("AST","TOV"), z.var="PTS",
            labels=paste(Pbox.sel$Player,", ",Pbox.sel$Season), palette=mypal)

plot3<-scatterplot(X, data.var=c("AST","TOV"), z.var="PTS",
            labels=paste(Pbox.sel$Player,", ",Pbox.sel$Season), palette=mypal,
            zoom=c(0.08,0.16,0.05,0.10))

#####################
# Bubble plots
#####################
teamSelected <- "LAL"
seasonSelected <- 2001
Tbox.sel <- subset(Tbox_all,Season==seasonSelected)

attach(Tbox.sel)
X <- data.frame(T=Team, P2p, P3p, FTp, AS=P2A+P3A+FTA)
detach(Tbox.sel)
labs <- c("2-point shots (% made)",
          "3-point shots (% made)",
          "free throws (% made)",
          "Total shots attempted")
bubbleplot(X, id="T", x="P2p", y="P3p", col="FTp",
           size="AS", labels=labs)

teamsSelected <- c("CHI", "UTA", "IND", "LAL")
seasonSelected <- 2001
Pbox.sel <- subset(Pbox, Team %in% teamsSelected & MIN>=1500 & Season==seasonSelected)

attach(Pbox.sel)
X <- data.frame(ID=Player, Team, V1=DREB/MIN, V2=STL/MIN,
                V3=BLK/MIN, V4=MIN)
detach(Pbox.sel)
labs <- c("Defensive Rebounds","Steals","Blocks",
          "Total minutes played")
plot5<-bubbleplot(X, id="ID", x="V1", y="V2", col="V3",
           size="V4", text.col="Team", labels=labs,
           title=paste0("NBA Players in ", seasonSelected),
           text.legend=TRUE, text.size=3.5, scale=FALSE)
## combine in dashboard
(plot3+plot4)/(plot1+plot5)
