class RequestURL{
  final String apiURL = "http://192.168.1.57:8000";
  final String anilistURL = "https://graphql.anilist.co";

  RequestURL();
  get getApiURL => this.apiURL;
  get getAnilistURL => this.anilistURL;
}