#pragma once

#define USERNAME_MAX_SIZE 32 + 1
#define PASSWORD_MAX_SIZE 45 + 1

typedef struct {
    char username[USERNAME_MAX_SIZE] ;
    char password[PASSWORD_MAX_SIZE] ;
} Credentials ;

typedef enum {
    MODERATORE = 0,
    GIOCATORE = 1,
    LOGIN = 2
} Role ;
