#define y1 3
#define x1 4
#define y2 5
#define x2 6
int recibe = 0;
void setup() {
pinMode(y1,INPUT);
pinMode(x1,INPUT);
pinMode(y2,INPUT);
pinMode(x2,INPUT);

//conectado
pinMode(y1,OUTPUT);
delay(1000);
digitalWrite(y1,0);
delay(500);
digitalWrite(y1,1);
delay(500);
pinMode(y1,INPUT);
delay(3000);
Serial.begin(9600);
}


void loop() {
if (Serial.available() > 0) {
    recibe = Serial.read();
    Serial.println(recibe);
    if(recibe == 1 ){prender_motores();}
    if(recibe == 2 ){apagar_motores();}
    if(recibe == 3 ){subir();}
    if(recibe == 4 ){bajar();}
  }

}
void prender_motores() {
pinMode(y1,OUTPUT);
pinMode(x1,OUTPUT);
pinMode(y2,OUTPUT);
pinMode(x2,OUTPUT);
digitalWrite(y1,1);
digitalWrite(x1,0);
digitalWrite(y2,0);
digitalWrite(x2,1);
delay(50);
pinMode(y1,INPUT);
pinMode(x1,INPUT);
pinMode(y2,INPUT);
pinMode(x2,INPUT);  
}

void apagar_motores(){
pinMode(y1,OUTPUT);
pinMode(x1,OUTPUT);
pinMode(y2,OUTPUT);
pinMode(x2,OUTPUT);
digitalWrite(y1,1);
digitalWrite(x1,1);
digitalWrite(y2,0);
digitalWrite(x2,0);
delay(50);
pinMode(y1,INPUT);
pinMode(x1,INPUT);
pinMode(y2,INPUT);
pinMode(x2,INPUT);  
}
void subir(){
pinMode(y1,OUTPUT);
digitalWrite(y1,0);
delay(50);
pinMode(y1,INPUT);
}
void bajar(){
pinMode(y1,OUTPUT);
digitalWrite(y1,1);
delay(50);
pinMode(y1,INPUT);
}

/*
//prender motores
pinMode(y1,OUTPUT);
pinMode(x1,OUTPUT);
pinMode(y2,OUTPUT);
pinMode(x2,OUTPUT);
digitalWrite(y1,1);
digitalWrite(x1,0);
digitalWrite(y2,0);
digitalWrite(x2,1);
delay(50);
pinMode(y1,INPUT);
pinMode(x1,INPUT);
pinMode(y2,INPUT);
pinMode(x2,INPUT);
delay(3000);

//apagar motores
pinMode(y1,OUTPUT);
pinMode(x1,OUTPUT);
pinMode(y2,OUTPUT);
pinMode(x2,OUTPUT);
digitalWrite(y1,1);
digitalWrite(x1,1);
digitalWrite(y2,0);
digitalWrite(x2,0);
delay(50);
pinMode(y1,INPUT);
pinMode(x1,INPUT);
pinMode(y2,INPUT);
pinMode(x2,INPUT);

//subir
pinMode(y1,OUTPUT);
digitalWrite(y1,0);
delay(50);
pinMode(y1,INPUT);

//bajar
pinMode(y1,OUTPUT);
digitalWrite(y1,1);
delay(50);
pinMode(y1,INPUT);
*/
