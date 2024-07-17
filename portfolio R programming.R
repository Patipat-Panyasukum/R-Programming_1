## Project I: hammer, scissors and paper game##
#Part I: greeting 
install.packages("languageserver")
sanook_game <- function(game_counted = 5){
  print("Hello! Welcome Welcome")
  user_name <- readline("What are your name:")
  print( paste("You have hammer, scissors and paper. Choose one at a time!,",user_name))
#Part II: Setting for game
  retry <- TRUE
  player_counted <- 1
  player_score <- 0
  comp_score <- 0
  your_hand <- c("hammer","scissors","paper")
#Part III: For loop & game rule
  while(player_counted <= game_counted){
    print( paste("Round:",player_counted))
    
    comp_hand <- sample(your_hand,1)
    user_hand <- readline("your weapons:")
    
    if(user_hand == comp_hand){
      print("draw")
      player_score <- player_score + 0
    } else if(user_hand == "hammer" & comp_hand == "scissors"|
              user_hand == "scissors" & comp_hand == "paper"|
              user_hand == "paper" & comp_hand == "hammer"){
      print("player win!")
      player_score <- player_score + 1
    } else {
      print("comp win!")
      comp_score <- comp_score + 1
    }
  # Round counted
    player_counted <- player_counted + 1;
  }
  if (player_score > comp_score) {
    print( paste("Congratulations,", user_name,"! You won the game!"))
  } else if (player_score < comp_score) {
    print(paste("Oh no,", user_name, "! The computer won the game. Better luck next time!"))
  } else {
    print("It's a tie! You both played well.")
  }
# Print final score outside the loop
  print(paste("Your final score:", player_score, "Comp final score",comp_score))
# while retry loop
  while(retry){
    retry_answer <- print(readline("Do you want to retry? (Y/N): "))
    if (retry_answer == "Y"){
    sanook_game()
    } else if (retry_answer == "N"){
      retry <- FALSE
      print("good bye!")
    } else {
      retry <- FALSE
      print("Good bye!")
      break
    }
  }
}
sanook_game()

##Project II: Chat bot to order pizza
##Menu book
df_menu <- data.frame(
  id = 1:4,
  pizza = c("Seafood", "Fourcheese", "Veggie", "Pepporoni"),
  price = c(500, 300, 350, 400)
)

##Setting
order <- TRUE
total_amount <- 0
order_detail <- list()
process <- c("Y", "D")

##loop
chatbot <- function() {
  print("Welcome to Pizza Papaya")
  flush.console()
  username <- readline("What's your name?: ")
  print(paste("Hi",username,"Here's our menu"))
  print(df_menu)
  
  while(order) {
    process <- readline("Type Y to order or Type D as Done:")
    flush.console()
    if (process == "Y") {
      order <- as.numeric(readline("Please type menu id of pizza: "))
      qty <- as.numeric(readline("How many set?:"))
      item_name <- df_menu[order,2]
      item_amount <- df_menu[order,3] * qty
      total_amount <- total_amount + item_amount
      order_detail[[length(order_detail) + 1]] <- list(
        pizza = item_name,
        quantity = qty,
        amount = item_amount
      )
    } else if (process == "D") {
      order <- FALSE
      print("Here is your order details")
      phone <- readline("Please enter your phone number: ")
      payment <- readline("Please select payment method ('cash' or 'credit card'):")
      print(paste("Your name, phone number, payment :", username, phone, payment))
      print("Order details:")
      for (i in 1:length(order_detail)) {
        complete <- order_detail[[i]]
        print(paste("[",complete$quantity,"set of]", complete$pizza, "[",complete$amount,"THB]"))
      }
      print(paste("Total amount:", total_amount, "THB"))
      print(paste("Free delivery for our lovely customers!"))
      print("Thank you for your support to Pizza Papaya!")
      break
    }
  }
}
chatbot()


