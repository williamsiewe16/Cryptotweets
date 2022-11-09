import tweepy
import boto3
import pandas as pd
import configparser
from datetime import datetime


config = configparser.ConfigParser(interpolation=None)
config.read_file(open('/app/.env'))


# credentials
API_KEY=config.get("TWITTER","API_KEY")
API_KEY_SECRET=config.get("TWITTER",'API_KEY_SECRET')
BEARER_TOKEN =config.get("TWITTER","BEARER_TOKEN")
ACCESS_TOKEN = config.get("TWITTER",'ACCESS_TOKEN')
ACCESS_TOKEN_SECRET = config.get("TWITTER",'ACCESS_TOKEN_SECRET')

CLIENT_ID=config.get("TWITTER",'CLIENT_ID')
CLIENT_SECRET=config.get("TWITTER",'CLIENT_SECRET')



def init():
    client = tweepy.Client( bearer_token = BEARER_TOKEN,
                            consumer_key = API_KEY,
                            consumer_secret = API_KEY_SECRET,
                            access_token = ACCESS_TOKEN,
                            access_token_secret = ACCESS_TOKEN_SECRET,
                            wait_on_rate_limit=True)

    return client



def extract_tweets(client, cryptos):
    or_query = " OR ".join(list(cryptos.keys()))
    QUERY = f"{or_query} -is:retweet"
    messages = []

    # get recent tweets
    tweets = client.search_recent_tweets(
        QUERY,
        tweet_fields = ['author_id','created_at','text','source','lang','geo'],
        max_results=100
    )

    # send messages to kafka
    for tweet in tweets[0]:
        crypto_list = list(set([cryptos[crypto] for crypto in  list(cryptos.keys()) if crypto.lower() in tweet.text.lower()]))
        if len(crypto_list) != 0:
            tweet.data["text"] = tweet.data["text"].replace("\n","")
            tweet.data["cryptos"] = crypto_list
            #tweet.data["sentiment"] = -1
            messages.append(tweet.data)

    print(len(messages))
    df = pd.DataFrame(data=messages)[['author_id','created_at','text','source','lang','cryptos']]

    print(df.head())
    #df.to_json("google.json",orient='records',lines=True)
    df.to_json(f"s3://cryptotweets-datalake/{datetime.now().strftime('%d-%m-%Y_%H-%M-%S')}.json",
          storage_options={'key': f'{config.get("AWS","KEY")}' ,
                           'secret': f'{config.get("AWS","SECRET")}'},orient='records',lines=True)
    



def load_tweets():
    pass

def main():
    # List of all cryptos
    cryptos = {
        "bitcoin": "bitcoin",
        "dogecoin": "dogecoin",
        "doge": "dogecoin",
        "shiba": "shibacoin",
        "shibacoin": "shibacoin",
        "ethereum": "ether",
        "ether": "ether"
    }

    client = init()


    extract_tweets(client, cryptos)


if __name__=="__main__":
    main()
