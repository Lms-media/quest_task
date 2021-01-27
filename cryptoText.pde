//всё что тебе нужно - это текст!
import controlP5.*;
ControlP5 cp5;
Textarea debugArea;
String cryptPath="", refPath="", textPath="";
PImage imageCrypt, imageRef;
int imgWidth;

void setup() {
  size(400, 205);

  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  IMAGE").setPosition(10, 10).setSize(120, 25);
  cp5.addButton("load_crypt_text").setCaptionLabel("LOAD  TEXT").setPosition(10, 40).setSize(120, 25);
  cp5.addButton("load_crypt").setCaptionLabel("LOAD  CRYPT  IMAGE").setPosition(10, 70).setSize(120, 25);
  cp5.addTextfield("key")
    .setPosition(10, 110)
    .setSize(120, 25)
    .setFont(createFont("arial", 15))
    .setAutoClear(false)
    .setCaptionLabel("")
    .setText("key")
    ;
  cp5.addButton("encrypt").setCaptionLabel("ENCRYPT  AND  SAVE").setPosition(10, 140).setSize(120, 25);  
  cp5.addButton("decrypt").setCaptionLabel("DECRYPT  AND  SAVE").setPosition(10, 170).setSize(120, 25);

  debugArea = cp5.addTextarea("decryptText")
    .setPosition(150, 10)
    .setSize(240, 185)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(0))
    .setColorBackground(color(180))
    .setColorForeground(color(180));
  ;
  debugArea.setText("CryptoText v1.0 by AlexGyver");
}

void draw() {
}

int getSeed() {  
  String thisKey = cp5.get(Textfield.class, "key").getText();
  int keySeed = 1;
  for (int i = 0; i < thisKey.length()-1; i++) 
    keySeed *= int(thisKey.charAt(i) * (thisKey.charAt(i)-thisKey.charAt(i+1)));  
  return keySeed;
}

void encrypt() {
  if (refPath.length() != 0 && textPath.length() != 0) {
    imageCrypt = loadImage(refPath);
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;

    String[] lines = loadStrings(textPath);    
    int textSize = 0;
    for (int i = 0; i < lines.length; i++) textSize += (lines[i].length() + 1);    

    if (textSize == 0) {
      debugArea.setText("Empty text file");
      return;
    }
    if (textSize >= imgSize) {
      debugArea.setText("Image is too small");
      return;
    }

    lines[lines.length-1] += '\0';
    textSize += 1;

    randomSeed(getSeed());

    int[] pixs = new int[textSize];  
    int counter = 0;

    for (int i = 0; i < lines.length; i++) {
      for (int j = 0; j < lines[i].length() + 1; j++) {

        int thisPix;
        while (true) {
          thisPix = (int)random(0, imgSize);         
          boolean check = true;                      
          for (int k = 0; k < counter; k++) {        
            if (thisPix == pixs[k]) check = false;   
          }
          if (check) {                               
            pixs[counter] = thisPix;                 
            counter++;                               
            break;                                   
          }
        }        
        
        int thisChar;
        if (j == lines[i].length()) thisChar = int('\n');  
        else thisChar = lines[i].charAt(j);       
        
        if (thisChar > 1000) thisChar -= 890;      

        int thisColor = imageCrypt.pixels[thisPix];

        int newColor = (thisColor & 0xF80000);
        newColor |= (thisChar & 0xE0) << 11;
        newColor |= (thisColor & (0x3F << 10));
        newColor |= (thisChar & 0x18) << 5;
        newColor |= (thisColor & (0x1F << 3));
        newColor |= (thisChar & 0x7);

        imageCrypt.pixels[thisPix] = newColor;
      }
    }
    imageCrypt.updatePixels();                  
    imageCrypt.save("crypt_image.bmp");         
    debugArea.setText("Finished");
  } else debugArea.setText("Image is not selected");
}

void decrypt() {
  if (cryptPath.length() != 0) {
    imageCrypt = loadImage(cryptPath);
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;

    randomSeed(getSeed());

    int[] pixs = new int[imgSize]; 
    String decryptText = "";    
    int counter = 0;

    while (true) {

      int thisPix;
      while (true) {    
        thisPix = (int)random(0, imgSize);
        boolean check = true;
        for (int k = 0; k < counter; k++) {
          if (thisPix == pixs[k]) check = false;
        }
        if (check) {
          pixs[counter] = thisPix;
          counter++;          
          break;
        }
      }

      int thisColor = imageCrypt.pixels[thisPix];

      int thisChar = 0;
      thisChar |= (thisColor & 0x70000) >> 11;  
      thisChar |= (thisColor & 0x300) >> 5;
      thisChar |= (thisColor & 0x7);

      if (thisChar > 130) thisChar += 890;     
      if (thisChar == 0) break;              
      decryptText += char(thisChar);            
    }
    debugArea.setText(decryptText);            

    String[] lines = new String[1];
    lines[0] = decryptText;
    saveStrings("decrypt_text.txt", lines);
  } else debugArea.setText("Crypted image is not selected");
}

void load_ref() {
  selectInput("", "selectRef");
}

void selectRef(File selection) {
  if (selection != null) {
    refPath = selection.getAbsolutePath();
    debugArea.setText(refPath);
  } else debugArea.setText("Image is not selected");
}

void load_crypt() {
  selectInput("", "selectCrypt");
}

void selectCrypt(File selection) {
  if (selection != null) {
    cryptPath = selection.getAbsolutePath();
    debugArea.setText(cryptPath);
  } else debugArea.setText("Crypted image is not selected");
}

void load_crypt_text() {
  selectInput("", "selectCryptText");
}

void selectCryptText(File selection) {
  if (selection != null) {
    textPath = selection.getAbsolutePath();
    debugArea.setText(textPath);
  } else debugArea.setText("Text file is not selected");
}
