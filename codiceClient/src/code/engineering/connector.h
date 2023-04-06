#pragma once

#include <stdbool.h>
#include <stdio.h>
#include <mysql/mysql.h>
#include "../database/dbUtils.h"
#include "../view/viewUtils.h"
#include "inout.h"

#define DB_HOST "DB.HOST"
#define DB_PORT "DB.PORT"
#define DB_NAME "DB.NAME"

#define DB_LOGIN_USER "LOGIN.USER"
#define DB_LOGIN_PASSWD "LOGIN.PASSWD" 

#define DB_MODERATORE_USER "MODERATORE.USER"
#define DB_MODERATORE_PASSWD "MODERATORE.PASSWD"

#define DB_GIOCATORE_USER "GIOCATORE.USER"
#define DB_GIOCATORE_PASSWD "GIOCATORE.PASSWD"

extern MYSQL *conn ;

bool connectToDatabase() ;