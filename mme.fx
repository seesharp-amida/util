// util/mme.fx

#define PI 3.14159265359

float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

// X軸回転行列生成
float4x4 getRotX(float r){
  float4x4 matRot = (float4x4)0;
   matRot[0] = float4(1,0,0,0); 
   matRot[1] = float4(0,cos(r),sin(r),0); 
   matRot[2] = float4(0,-sin(r),cos(r),0); 
   matRot[3] = float4(0,0,0,1);
   return matRot;
}

// Y軸回転行列生成
float4x4 getRotY(float r){
  float4x4 matRot = (float4x4)0;
   matRot[0] = float4(cos(r),0,-sin(r),0); 
   matRot[1] = float4(0,1,0,0); 
   matRot[2] = float4(sin(r),0,cos(r),0); 
   matRot[3] = float4(0,0,0,1); 
   return matRot;
}

// Z軸回転行列生成
float4x4 getRotZ(float r){
  float4x4 matRot = (float4x4)0;
   matRot[0] = float4(cos(r),sin(r),0,0); 
   matRot[1] = float4(-sin(r),cos(r),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   return matRot;
}

// クォータニオンの乗算処理
float4 qmul(float4 q1, float4 q2)
{
  return float4(
    q1.w * q2.x + q1.x * q2.w + q1.z * q2.y - q1.y * q2.z,
    q1.w * q2.y + q1.y * q2.w + q1.x * q2.z - q1.z * q2.x,
    q1.w * q2.z + q1.z * q2.w + q1.y * q2.x - q1.x * q2.y,
    q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
  );
}

// 軸指定回転。axisは単位ベクトルとする
float4 rotateAxis(float3 p, float3 axis, float rot){
  float s = sin(rot*0.5);
  float c = cos(rot*0.5);
  float4 q = float4( axis * s, c);
  float4 r = float4(-axis * s, c);
  
  return qmul(qmul(r, float4(p, 0)), q);
}

// 角度をラジアンに変換する
float angToRad(float angle){
  return angle / 360.0 * 2 * PI;
}