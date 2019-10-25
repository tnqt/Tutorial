#include "pch.h"
#include "Date.h"

Date::Date(int year, int month, int day)
	: m_year(year), m_month(month), m_day(day)
	{
		
	}

int Date::getYear()
{
	return m_year;
}

int Date::getMonth()
{
	return m_month;
}

int Date::getDay()
{
	return m_day;
}