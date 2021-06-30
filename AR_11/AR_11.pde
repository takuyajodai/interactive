//2つのマーカを認識してそれぞれに異なるオブジェクトを表示する
import processing.video.*; //ビデオを利用する際に必要
import jp.nyatla.nyar4psg.*; //ARToolkitを利用する際に必要

int camNo = 0;
int isBlueFlag,flagment = 0;
int interval = 5;
boolean oneTimeRun, oneTimeCheck;
float pre_t, pre_t2;

Capture cam;
MultiMarker nya;

//ゲームモード 0:タイトル 1:ゲーム 2:終了
int mode;

//時間関係の変数
long t_start; // 現在の状態になった時刻[ミリ秒]
long t;      // 現在の状態になってからの経過時間[秒]


//読み込み用の3Dモデル
PShape red_flag, blue_flag;

void setup() {
  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);
  //【注意】使用するカメラの解像度に合わせないとエラーになる
  String[] cameras = Capture.list(); //利用可能なカメラ一覧を取得
  //println("利用可能カメラ一覧");
  for (int i = 0; i < cameras.length; i++) {  //一覧を表示
    println("[" + i + "] " + cameras[i]);
  }
  //println("-------------------------------");

  //println("接続中のカメラ；[" + camNo + "] " + cameras[camNo]);
  cam = new Capture(this, cameras[camNo]); //カメラに接続

  //複数マーカ管理用オブジェクト
  nya=new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  //マーカ用画像の登録
  nya.addNyIdMarker(1, 100);//NyId=0のマーカーの登録（0番目のマーカーとして参照）
  nya.addNyIdMarker(2, 100);//NyId=1のマーカーの登録（1番目のマーカーとして参照）
  
  //3Dオブジェクトの読み込み
  red_flag = loadShape("tinker_red.obj");
  blue_flag = loadShape("tinker_blue.obj");
  
  //変数の初期化
  mode = 0;
  
  cam.start(); //カメラ撮影開始
}

void draw() {
  t = (millis() - t_start) / 1000; // 経過時間を更新
  //カメラ存在チェック
  if (cam.available() !=true) {
    return;
  }
  cam.read();//カメラから画像を読み込み
  nya.detect(cam);//マーカの認識
  background(0);
  nya.drawBackground(cam);//frustumを考慮した背景描画
  
  int nextMode = 0;
  if(mode == 0) {
    nextMode = title();
  } else if(mode == 1) {
    nextMode = game();
  } else if(mode == 2) {
    nextMode = ending();
  }
  if(mode != nextMode){ t_start = millis(); } // 状態が遷移するので、現在の状態になった時刻を更新する
  mode = nextMode;
}
void gameInit() {
  oneTimeRun = true;
  oneTimeCheck = true;
  t_start = 0;
  t = 0;
}

int title() {
  gameInit();
  textSize(30);
  textAlign(CENTER);
  text("AR旗振りゲーム", width * 0.5, height * 0.3);
  text("Press 'z' key to start", width * 0.5, height * 0.7);
  // 'z'でゲームスタート
  if(keyPressed && key == 'z') { 
    return 1; // start game
  }
  return 0;
}

int game() {
  //println("----------------");
  background(0);
  nya.drawBackground(cam);//frustumを考慮した背景描画
  text(t + "game", width * 0.5, height * 0.5);
  
  //interbal時間ごとに判定(最初は含まない)
  if(t%(interval) == 0 && t != 0 && oneTimeCheck) {
    pre_t2 = t;
    if(check() == 0) {
    //エンディングへ
    return 2;
    }
  }
  if( t == pre_t2 + 2 && oneTimeCheck == false) oneTimeCheck = true;
  
  
  //5秒ごとに指示をランダムで指示を変える
  if( t%(interval)==0 && oneTimeRun){
    pre_t = t;
    flagment = designateFlags();
    println("flagment:"+flagment);  
  }
  if( t == pre_t + 2 && oneTimeRun == false) oneTimeRun = true;
 
  //指示を行う
  displayOrder();
  
  //3Dモデルの表示
  //マーカ0に赤を割り当て
  if (nya.isExist(0)) {
    nya.beginTransform(0);
      shape(red_flag);
    nya.endTransform();
  }
  //マーカ1に青を割り当て
  if (nya.isExist(1)) {
    nya.beginTransform(1);
      shape(blue_flag);
    nya.endTransform();
  }
   
  
  //続ける
  return 1;
}

int ending() {
  textSize(30);
  textAlign(CENTER);
  text("GAME OVER", width * 0.5, height * 0.5);
  text("Press 'z' to restart.", width * 0.5, height * 0.7);
  // 'z'でリスタート
  if(keyPressed && key == 'z') {
    return 0;
  }
  return 2;
}

int check() {
  oneTimeCheck = false;
  //もし指示が赤なら
  if(flagment == 0) {
    // マーカー赤が存在したら
    if (nya.isExist(0)) {
      print("red ok ");
      text("red ok", width * 0.6,height * 0.2);
      return 1;
    }
  }
  //もし指示が青なら
  if(flagment == 1) {
    // マーカー青が存在したら
    if (nya.isExist(1)) {
      print("blue ok ");
      text("blue ok", width * 0.6,height * 0.2);
      return 1;
    }  
  }
  
  return 0;
}

// isBlueFlag 0: 赤 1: 青
int designateFlags(){
  //インターバルごとに一回のみチェック
  oneTimeRun = false;
  float val = random(2);
  isBlueFlag = int(val);
  println("isBlueFlag" + isBlueFlag);
  return isBlueFlag;
}

void displayOrder(){
  textSize(30);
  textAlign(CENTER);
  fill(100);
  if(flagment==0){
    textSize(50);
    textAlign(CENTER);
    fill(90,20,20);
    text("Raise the red flag !!",width * 0.5,height * 0.2 );
  }
  else if(flagment==1){
    textSize(50);
    textAlign(CENTER);
    fill(10,20,80);
    text("Raise the blue flag !!",width * 0.5,height * 0.2 );
  }
}
