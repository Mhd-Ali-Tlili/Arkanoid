// arkanoid = https://www.dailymotion.com/video/x5f1vv
/////////////////////////////////////////////////////
//
// Arkanoid
// DM2 "UED 131 - Programmation impérative" 2022-2023
// NOM         : TLILI
// Prénom      : Mohamed-Ali
// N° étudiant : 20222867
//
// Collaboration avec : Université Paris-Saclay Campus d'Evry 
//
/////////////////////////////////////////////////////
import processing.sound.*;

//===================================================
// les variables globales
//===================================================

/////////////////////////////
// Pour les effets sonores //
SoundFile soundBrique;
SoundFile soundGameOver;
SoundFile soundIntro;
SoundFile soundLetsGo;
SoundFile soundMur;
SoundFile soundRaquette;
/////////////////////////////

/////////////////////////////
// Pour la balle           //
float balleX;
float balleY;
int balleD=12;
int balleVitesse;
float newBalleX;
float newBalleY;
float balleVx;
float balleVy;
float angle;
/////////////////////////////

/////////////////////////////
// Pour la raquette        //
int raquetteL=60;
int raquetteH=10;
int raquetteY=576;
int raquetteX;
/////////////////////////////

/////////////////////////////
// Pour la zone de jeu     //
int maxX=680;
int minX=30;
int minY=30;
int centreX=355;
/////////////////////////////

/////////////////////////////
// Pour les briques        //
boolean[][] briques = new boolean[8][13];
color[] couleursLignes = new color[8];
int largeurBrique = 50;
int hauteurBrique = 27;
int espaceBrique = 1;  // Espace entre chaque brique
int nbBriques=104;
float x;
float y;
/////////////////////////////

/////////////////////////////
// Pour le "boss"          //
int score=0;
/////////////////////////////

/////////////////////////////
// Pour le contrôle global //
/////////////////////////////

////////////////////////////////////
// Pour la gestion de l'affichage //
int etat;
int INIT =0;
int GO =1;
int OVER =2;
int highScore=0;
int nbVies=3;



////////////////////////////////////

//===================================================
// l'initialisation
//===================================================
void setup() {
  size(960, 630);
  angle=random(5*PI/4,7*PI/4);
  initJeu();
  couleursLignes[0] = color(255, 0, 0); // Rouge
  couleursLignes[1] = color(0, 255, 0); // Vert
  couleursLignes[2] = color(0, 0, 255); // Bleu
  couleursLignes[3] = color(255, 255, 0); // Jaune
  couleursLignes[4] = color(255, 0, 255); // Magenta
  couleursLignes[5] = color(0, 255, 255); // Cyan
  couleursLignes[6] = color(255, 127, 0); // Orange
  couleursLignes[7] = color(127, 127, 127); // Gris
  etat=INIT;
  // Load sound files
  soundBrique = new SoundFile(this, "brique.mp3");
  soundGameOver = new SoundFile(this, "gameover.mp3");
  soundIntro = new SoundFile(this, "intro.mp3");
  soundLetsGo = new SoundFile(this, "letsgo.mp3");
  soundMur = new SoundFile(this, "mur.mp3");
  soundRaquette = new SoundFile(this, "raquette.mp3");

  // Play intro sound
  soundIntro.play();
}

//===================================================
// l'initialisation de la balle et de la raquette
//===================================================
void initBalleEtRaquette() {
  balleX = 355;
  balleY = 565;
  raquetteX = 355;  
  afficheBalle();
  afficheRaquette();
  balleVitesse=int(random(50,65));
  balleVx=balleVitesse*cos(angle);
  balleVy=balleVitesse*sin(angle);
}

//===================================================
// l'initialisation des briques
//===================================================
void initBriques() {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 13; j++) {
      briques[i][j] = true;
    }
  }
}

// Affichage des briques actives
void afficheBriques() {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 13; j++) {
      if (briques[i][j]) {
        x = minX*1.72 + j * (largeurBrique+espaceBrique);
        y = minY*3.5 + i * (hauteurBrique+espaceBrique);
        fill(couleursLignes[i]); // Utilise la couleur de la ligne
        rect(x, y, largeurBrique, hauteurBrique,5);
        noFill();
      }
    }
  }
}

//===================================================
// l'initialisation de la partie
//===================================================
void initJeu() {
  initBalleEtRaquette();
  initBriques();
}

//===================================================
// la boucle de rendu
//===================================================
void draw() {
  if (etat==INIT){
  afficheJeu();
}else if (etat==GO){
  afficheJeu();
  rebondMurs();
  deplaceBalle();
  miseAJourBalle();
  rebondRaquette();
  rebondBriques(balleX, balleY, newBalleX, newBalleY);
  rebondBoss(balleX, balleY, newBalleX, newBalleY);
   if (balleY > height) {
     nbVies--; // Décrémente le nombre de vies
     if (nbVies > 0) {
        initBalleEtRaquette(); // Réinitialise la position de la balle et de la raquette
      } else {
        score = 0;
        etat = OVER;
        soundGameOver.play();
      }
    }
  } else if (etat == OVER) {
    afficheEcranOver("Vous avez perdu");
  }
  
}



//===================================================
// gère les rebonds sur les murs
//===================================================
void rebondMurs() {
  if (newBalleX>maxX-balleD){
  newBalleX=maxX-balleD;
  balleVx=-balleVx;
  soundMur.play();
  }else if (newBalleX<minX+balleD){
  newBalleX=minX+balleD;
  balleVx=-balleVx;
  soundMur.play();
  }else if (newBalleY<minY+balleD){
  newBalleY=minY+balleD;
  balleVy=-balleVy;
  soundMur.play();
  }
}

//===================================================
// gère le rebond sur la raquette
//===================================================
void rebondRaquette() {
  if (balleY<raquetteY-raquetteH/2 && (newBalleY>=(raquetteY-raquetteH/2)-balleVitesse && (newBalleX>raquetteX-raquetteL/2 && newBalleX<raquetteX+raquetteL/2))){
    newBalleY=balleY;
    balleVy=-balleVy;
    soundRaquette.play();
  }
}

//===================================================
// gère le rebond sur une "boîte"
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
// (bx, by) = le coin supérieur gauche de la boîte
// (bw, bh) = la largeur et la hauteur de la boîte
// --------
// résultat = vrai si rebond / faux sinon
// --------
// met à jour la vitesse de la balle en fonction du 
// rebond
//===================================================
boolean rebond(float x1, float y1, float x2, float y2, 
  float bx, float by, float bw, float bh) {
    if ((x1>bx+bw && x2<bx+bw+balleVitesse && y2>by&& y2<by+bh)||(x1<bx&&x2>bx-balleVitesse&&y2>by&&y2<by
    +bh)){
      balleVx=-balleVx;
      return true;
    }
    else if ((y1>by+bh&&y2<by+bh+balleVitesse&&x2>bx&&x2<bx+bw)||(y1<by&&y2>by-balleVitesse&&x2>bx&&x2<bx+bw)){
      balleVy=-balleVy;
      return true;
    }else{
      
  return false;
    }
}

//===================================================
// gère le rebond sur les briques
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
//===================================================
void rebondBriques(float x1, float y1, float x2, float y2) {
for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 13; j++) {
      if (briques[i][j]) {
        x = minX * 1.72 + j * (largeurBrique + espaceBrique);
        y = minY * 3.5 + i * (hauteurBrique + espaceBrique);
        
        if (rebond(x1, y1, x2, y2, x, y, largeurBrique, hauteurBrique)) {
          score++;// Incrémente le score
          if (score>highScore){
            highScore=score;
          }
          nbBriques--;
          briques[i][j] = false;// Désactive la brique
          soundBrique.play();
        }
      }
    }
  }
}

//===================================================
// gère le rebond sur le boss
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
//===================================================
void rebondBoss(float x1, float y1, float x2, float y2) {
if (nbBriques==0){
  if (rebond (x1,y1,x2,y2,255,100,200,200)){
  score+=10;
  if (score>highScore){
    highScore=score;
  }
  }
}
}


//===================================================
// calcule la nouvelle position de la balle
//===================================================
void deplaceBalle() {
  newBalleX=balleX+balleVx;
  newBalleY=balleY+balleVy;
}

//===================================================
// met à jour la position de la balle
//===================================================
void miseAJourBalle() {
  balleX=newBalleX;
  balleY=newBalleY;
}

//===================================================
// affiche un écran, avec un message
// --------------------------------------------------
// msg = le message à afficher
//===================================================
void afficheEcran(String msg) {
   if (etat==INIT){
    fill(255);
    PFont fonte = createFont ("joystix.ttf",50);
    textFont(fonte);
    text(msg, centreX-170 , 480);
    PFont fonte1 = createFont ("joystix.ttf",20);
    textFont(fonte1);
    text("PRESS <SPACE> TO START",centreX-170, 520);
    PImage img = loadImage("arkanoid.png");
    image(img, centreX-230,320,500,100);
  }
}

void afficheEcranOver(String msg) {
  fill(255);
  PFont fonte = createFont("joystix.ttf", 50);
  textFont(fonte);
  text(msg, centreX - 305, 480);
  PFont fonte1 = createFont("joystix.ttf", 20);
  textFont(fonte1);
  text("PRESS <R> TO RESTART", centreX - 170, 520);
}

//===================================================
// fait le dessin de pavage au fond
//===================================================
void pavage() {
  for (int i=30;i<650;i+=76){
   for (int j=0; j<maxX;j+=130){
     PImage img = loadImage("tile.png");
  image(img, j,i);
  }
  }
  for (int i=-8;i<650;i+=76){
   for (int j=65; j<maxX;j+=130){
     PImage img = loadImage("tile.png");
  image(img, j,i);
  }
  }
}

//===================================================
// affiche le cadre
//===================================================
void cadre() {
  for (int i=0;i<630;i+=105){
   for (int j=40; j<700;j+=105){
     PImage img = loadImage("wall1.png");
  image(img, 0,i);
  PImage img2 = loadImage("wall2.png");
  image(img2, 0,j);
  }
  }
  for (int i=0;i<660;i+=105){
   for (int j=40; j<700;j+=105){
     PImage img = loadImage("wall1.png");
  image(img, maxX,i);
  PImage img2 = loadImage("wall2.png");
  image(img2, maxX,j);
  }
  }
  PImage img = loadImage("top.png");
  image(img, 0,0);
  
}

//===================================================
// formate le score sur 6 chiffres
// --------------------------------------------------
// score = le score à afficher
// --------
// résultat = une chaîne de caractères sur 6 chiffres
//===================================================
String formatScore(int score) {
  String formattedScore = nf(score, 5); // Formate le score avec 5 chiffres
  String formattedHighScore = nf(highScore, 5); // Formate le high score avec 5 chiffres

  text(formattedScore, 790, 120);
  text(formattedHighScore, 790, 220);
  return "";
}

//===================================================
// affiche le cartouche de droite
//===================================================
void cartouche() {
 fill(0);
rectMode(CORNER);
rect(710, 0, 250, 630);

PImage img = loadImage("arkanoid.png");
image(img, 710, 0);

PFont fonte = createFont("joystix.ttf", 20);
textFont(fonte);

fill(255, 0, 0);
text("1UP", 800, 100);

fill(255);
text("HIGH SCORE", 750, 200);

String[] centerTexts = {
  "COPYRIGHT",
  "M-A.TLILI",
  "@ 2022"
};

int centerXReference = 800; // Position horizontale de référence
int centerY = 550; // Position verticale de départ

for (String text : centerTexts) {
  float textWidth = textWidth(text);
  int centerX = centerXReference - (int)(textWidth / 2);
  text(text, centerX, centerY);
  centerY += 20; // Espacement vertical entre les textes
  
  
}

  fill(255);
  text("VIES: " + nbVies, 800, 300); // Affiche le nombre de vies restantes

}

//===================================================
// affiche le boss dans sa cage
//===================================================
void boss() {
  pushMatrix();
  translate(255,100);
  scale(0.5);
  
  // Corps du lapin
  fill(255);
  ellipse(200, 250, 150, 150);
  
  // Tête du lapin
  ellipse(200, 150, 100, 100);
  
  // Oreilles
  fill(150);
  ellipse(160, 120, 40, 60);
  ellipse(240, 120, 40, 60);
  
  // Yeux
  fill(0);
  ellipse(180, 140, 20, 20);
  ellipse(220, 140, 20, 20);
  
  // Nez
  fill(255, 100, 100);
  ellipse(200, 160, 10, 10);
  
  // Bouche
  noFill();
  arc(200, 160, 40, 20, 0, PI);
  
  // Corps du lapin
  fill(255);
  ellipse(200, 300, 120, 80);
  
  // Pattes
  fill(150);
  rect(160, 280, 20, 40);
  rect(220, 280, 20, 40);
  
  // Queue
  fill(255);
  ellipse(260, 310, 20, 20);
  
  PImage img = loadImage("cage.png");
  image(img,0,0);
  popMatrix();
}


//===================================================
// affiche la balle
//===================================================
void afficheBalle() {
  noStroke();
  fill(255);
  ellipse(balleX,balleY,balleD,balleD);
  stroke(0);
}

//===================================================
// affiche la raquette
//===================================================
void afficheRaquette() {
  rectMode(CENTER);
  noStroke();
  fill(255);
  rect(raquetteX,raquetteY,raquetteL,raquetteH,10);
  stroke(0);
}

//===================================================
// affiche le jeu
//===================================================
void afficheJeu() {
  pavage();
  cadre();
  afficheBalle();
  afficheRaquette();
  boss();
  afficheBriques();
  cartouche();
  formatScore(score);
  afficheEcran("GET READY");
}

//===================================================
// gère les interactions clavier
//===================================================
void keyPressed() {
  if (etat == INIT) {
    etat = GO;
    soundLetsGo.play();
  } else if (etat == OVER && key == 'r') {
    etat = INIT;
    initJeu(); // Réinitialise le jeu
    nbVies = 3; // Réinitialise le nombre de vies
    soundIntro.play();
  }
}

//===================================================
// gère les interactions souris
//===================================================
void mouseMoved() {
  if (etat==GO){
  raquetteX=mouseX;
  }
  if (raquetteX<30+raquetteL/2){
    raquetteX=30+raquetteL/2;
  }else if (raquetteX>680-raquetteL/2){
    raquetteX=680-raquetteL/2;
  }  
}
