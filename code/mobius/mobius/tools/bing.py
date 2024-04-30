import os

os.environ["BING_SUBSCRIPTION_KEY"] = "<key>"
os.environ["BING_SEARCH_URL"] = "https://api.bing.microsoft.com/v7.0/search"

from langchain_community.utilities import BingSearchAPIWrapper
from langchain.tools.bing_search import BingSearchRun

bing_search = BingSearchRun(api_wrapper=BingSearchAPIWrapper(k=5))
