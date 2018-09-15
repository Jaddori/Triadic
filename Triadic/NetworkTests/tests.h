#pragma once

#include <iostream>
#include <Windows.h>

#define FOREGROUND_WHITE FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE

#define TEST( func ) \
	if( !func() ) \
	{ \
		HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE); \
		SetConsoleTextAttribute(hConsole, FOREGROUND_INTENSITY | FOREGROUND_RED); \
		printf( "\t%s failed.\n", #func ); \
		result = false; \
		SetConsoleTextAttribute(hConsole, FOREGROUND_WHITE); \
	} \
	else \
	{ \
		HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE); \
		SetConsoleTextAttribute(hConsole, FOREGROUND_INTENSITY | FOREGROUND_GREEN); \
		printf( "\t%s succeeded.\n", #func ); \
		SetConsoleTextAttribute(hConsole, FOREGROUND_WHITE); \
	}