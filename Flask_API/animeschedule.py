import mysql.connector
from sqlalchemy import create_engine
import pandas as pd
import requests
from datetime import datetime
class Animeschedule():

  def createschedule(self):
    query = '''
    query ($id: Int, $page: Int, $perPage: Int, $season: MediaSeason, $seasonYear:Int) {
        Page (page: $page, perPage: $perPage) {
            pageInfo {
                total
                currentPage
                lastPage
                hasNextPage
                perPage
            }
            media (id: $id, season: $season, seasonYear:$seasonYear) {
                id
                episodes
                title {
                    romaji
                }
                startDate{
                  month
                }
            }
            
        }
    }
    '''
    variables = {'season': "SPRING",'seasonYear': 2021,'page': 1,'perPage': 50}
    url = 'https://graphql.anilist.co'
    json = {'query': query, 'variables': variables}
    print(type(json))
    response = requests.post(url, json=json)
    print(response.content)
  
  def currentseason():
    datetime.now().month()
    if datetime.now().month() >= 1 and datetime.now().month() <= 3:
      return "WINTER"
    elif datetime.now().month() >= 1 and datetime.now().month() <= 3:
      return "SPRING"
    elif datetime.now().month() >= 1 and datetime.now().month() <= 3:
      return "SUMMER"
    elif datetime.now().month() >= 1 and datetime.now().month() <= 3:
      return "FALL"