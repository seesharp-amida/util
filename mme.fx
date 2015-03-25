// util/mme.fx

#define PI 3.14159265359

float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

// 2ベクトルの外積
float3 cross(float3 v1, float3 v2){
  return float3( (v1.y * v2.z) - (v1.z * v2.y), (v1.z * v2.x) - (v1.x * v2.z), (v1.x * v2.y) - (v1.y * v2.x) );
}

// 2ベクトルの内積
float dot(float3 v1, float3 v2){
  return float3( (v1.y * v2.z) + (v1.z * v2.y), (v1.z * v2.x) + (v1.x * v2.z), (v1.x * v2.y) + (v1.y * v2.x) );
}

// 2ベクトルのなす角
float getAngle(float3 v1, float3 v2){
  return acos(dot(v1, v2) / (length(v1) * length(v2)));
}

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

float3 rotateX(float3 pos, float r){
  return mul(pos, getRotX(r));
}

float3 rotateY(float3 pos, float r){
  return mul(pos, getRotY(r));
}

float3 rotateZ(float3 pos, float r){
  return mul(pos, getRotZ(r));
}

float3 rotateXYZ(float3 pos, float3 rotation){
  pos = rotateX(pos, rotation.x);
  pos = rotateY(pos, rotation.y);
  pos = rotateZ(pos, rotation.z);
  return pos;
}
float3 rotateXZY(float3 pos, float3 rotation){
  pos = rotateX(pos, rotation.x);
  pos = rotateZ(pos, rotation.z);
  pos = rotateY(pos, rotation.y);
  return pos;
}
float3 rotateYXZ(float3 pos, float3 rotation){
  pos = rotateY(pos, rotation.y);
  pos = rotateX(pos, rotation.x);
  pos = rotateZ(pos, rotation.z);
  return pos;
}
float3 rotateYZX(float3 pos, float3 rotation){
  pos = rotateY(pos, rotation.y);
  pos = rotateZ(pos, rotation.z);
  pos = rotateX(pos, rotation.x);
  return pos;
}
float3 rotateZXY(float3 pos, float3 rotation){
  pos = rotateZ(pos, rotation.z);
  pos = rotateX(pos, rotation.x);
  pos = rotateY(pos, rotation.y);
  return pos;
}
float3 rotateZYX(float3 pos, float3 rotation){
  pos = rotateZ(pos, rotation.z);
  pos = rotateY(pos, rotation.y);
  pos = rotateX(pos, rotation.x);
  return pos;
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

float4x4 createLookAt(float3 eye, float3 lookat, float3 up){
  float3 z = normalize(lookat - eye);
  float3 x = normalize(cross(up,z));
  float3 y = normalize(cross(z,x));
  
  float4x4 res = {
    x.x, x.y, x.z, 0,
    y.x, y.y, y.z, 0,
    z.x, z.y, z.z, 0,
    eye.x, eye.y, eye.z, 1
  };
  return res;
}

// 角度をラジアンに変換する
float angToRad(float angle){
  return angle / 360.0 * 2 * PI;
}

float4 colorInt(int r, int g, int b, int a){
  return float4(r / 256.0, g / 256.0, b / 256.0, a / 256.0);
}

float blendOverrayScalar(float a, float b){
  float result;
  if (a < 0.5){ result = a * b * 2; }
  else{ result = 2 * (a + b - a * b) - 1; }
  
  if (result > 1) result = 1;
  
  return result;
}

float3 blendOverray(float3 a, float3 b){
  float3 result;
  
  result.r = blendOverrayScalar(a.r, b.r);
  result.g = blendOverrayScalar(a.g, b.g);
  result.b = blendOverrayScalar(a.b, b.b);
  
  return result;
}
