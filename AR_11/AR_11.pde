//2つのマーカを認識してそれぞれに異なるオブジェクトを表示する
import processing.video.*; //ビデオを利用する際に必要
import jp.nyatla.nyar4psg.*; //ARToolkitを利用する際に必要

int camNo = 0;
Capture cam;
MultiMarker nya;

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
  
  cam.start(); //カメラ撮影開始
}

void draw() {
  //カメラ存在チェック
  if (cam.available() !=true) {
    return;
  }
  cam.read();//カメラから画像を読み込み
  nya.detect(cam);//マーカの認識
  background(0);
  nya.drawBackground(cam);//frustumを考慮した背景描画
}
