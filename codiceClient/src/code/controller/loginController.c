#include "loginController.h"

static bool switchRole(Role role) {
    char *databaseName = getenv("DB.NAME") ;
    char *username ;
    char *password ;

    switch(role) {
        case MODERATORE :
            username = getenv(DB_MODERATORE_USER) ;
            password = getenv(DB_MODERATORE_PASSWD) ;
            break ;
        case GIOCATORE :
            username = getenv(DB_GIOCATORE_USER) ;
            password = getenv(DB_GIOCATORE_PASSWD) ;
            break ;
        case LOGIN :
            username = getenv(DB_LOGIN_USER) ;
            password = getenv(DB_LOGIN_PASSWD) ;
            break ;
    }

    if (username == NULL || password == NULL || databaseName == NULL) {
        printError("Errore : Variabili d'Ambiente Non Trovate") ;
        return false ;
    }

    if (mysql_change_user(conn, username, password, databaseName) != 0) {
        print_sql_error(conn, "Errore SQL: Impossibile Cambiare Privilegi Utente") ;
        return false ;
    }

    return true ;
}

static bool successLogin(Role myRole, char* username) {
    clearScreen() ;
    showAppTitle() ;
    bool flag = false;
    if (switchRole(myRole) == false) {
        return false;
    }

    switch (myRole) {
        case MODERATORE :
            moderatoreController(username) ;
            flag = true ;
            break;
        case GIOCATORE :
            giocatoreController(username) ;
            flag = true ;
            break;
        case LOGIN :
            printError("login fallito");
            break;
    }
    
    switchRole(LOGIN) ;
    return flag;
}

static void login(){
    clearScreen();
    showAppTitle();
    puts("\t\t\t\t|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|");
	puts("\t\t\t\t|             LOGIN               |");
	puts("\t\t\t\t|_________________________________|\n");
    Credentials creds ;
    int failed_attempts = 0;

    do {
        if(failed_attempts == 3){
            return;
        }
        memset(&creds, 0, sizeof(Credentials)) ;
        Role myRole = LOGIN ;

        if (promptLoginAndRegistration(&creds)) {
            myRole = logAsUser(creds) ;
            if (myRole == LOGIN) {
                printError("LOGIN FALLITO: Username e/o Password non corrispondono ad alcun utente") ;
                failed_attempts ++;
            }
            else {
                if(successLogin(myRole, creds.username)){
                    return;
                }
            }
        }else{
            failed_attempts ++;
        }
    } while (true) ;    
}

static bool registration(){
    clearScreen();
    showAppTitle();
    puts("\t\t\t\t|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|");
	puts("\t\t\t\t|          REGISTRAZIONE          |");
	puts("\t\t\t\t|_________________________________|\n");
    Credentials creds;
    int failed_attempts = 0;
    do {
        if(failed_attempts == 3){
            return false;
        }
        memset(&creds, 0, sizeof(Credentials));
        if(promptLoginAndRegistration(&creds)){
            if(registerNewPlayer(creds)){
                printSuccess("Giocatore registrato correttamente");
                return true;
            }
        }
        failed_attempts ++;
    } while (true) ;
    
}

void loginController() {
main_menu:
    clearScreen();
    showAppTitle();
    puts("\t\t\t\t|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|");
	puts("\t\t\t\t|         MENU PRINCIPALE         |");
	puts("\t\t\t\t|_________________________________|\n");
    int input;
    int failed_attempts = 0;
    while (true) {
        if(failed_attempts == 3){
            goto main_menu;
        }
        input = promptInitialMenu();
		switch (input)
        {
            case 1:
                login();
                goto main_menu;
                break;
            case 2:
                if(!registration()){
                    goto main_menu;
                }
                break;
            case 3:
                puts("");
                printf("\033[41m%s\033[0m","------------------------ARRIVEDERCI------------------------");
                puts("");
                puts("");
                mysql_close(conn);
                exit(0);
            default:
                printError("Scegli tra le opzioni proposte!");
                failed_attempts ++;
                break;
        }
	}
    
}

