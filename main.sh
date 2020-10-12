# Title: Azure Subscription Mover
# Author: Arno Franken
# Date: 12-10-2020
# Company: Cyber Cloud
# URL: https://www.cybercloud.cc

read varname
echo Hallo $varname ! Wat fijn om je weer te zien.
echo Laten we eerst even kijken of je ingelogd bent.
az login
echo Nu kunnen we verder, jouw Azure Subscriptions zijn de volgende:
az account list
