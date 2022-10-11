#include <wiringPi.h> 
#include <softPwm.h> 
#include <stdio.h> 
#include <stdlib.h> 
 
// Definition 
#define REDLIGHT 17   /*Redlight on PIN 17*/ 
#define GREENLIGHT 18 /*Greenlight on PIN 18*/ 
 
// Function prototype 
void blinkingOne(int numberOfTimePerSecond); 
void blinkingTwo(); 
 
void blinkingOne(int numberOfTimePerSecond) 
{ 
    int counter = 0; 
    while (counter <= 1)//While loop represents a  
    { 
        for (int j = 0; j <= numberOfTimePerSecond; j++) 
        { 
            pwmWrite(GREENLIGHT, 1024); 
            softPwmWrite(REDLIGHT, 100); 
            delay(250); 
            pwmWrite(GREENLIGHT, 0); 
            softPwmWrite(REDLIGHT, 0); 
            delay(250); 
        } 
        counter++; 
    } 
} 
 
void blinkingTwo() 
{ 
    int counter = 0; // Initialize counter to 0 
    while (counter < 2) 
    { // While loop to run instruction twice (1 second) 
        pwmWrite(GREENLIGHT, 256); 
        for (int j = 0; j < 4; j++) 
        { 
            softPwmWrite(REDLIGHT, 100); 
            delay(62.5); 
            softPwmWrite(REDLIGHT, 0); 
            printf("Red blinked\n"); 
            delay(62.5); 
        } 
        pwmWrite(GREENLIGHT, 0); 
        for (int j = 0; j < 4; j++) 
        { 
            softPwmWrite(REDLIGHT, 100); 
            delay(62.5); 
            softPwmWrite(REDLIGHT, 0); 
            printf("Red blinked\n"); 
            delay(62.5); 
        } 
        counter++; 
    } 
} 
 
int main() 
{ 
    // Give sudo priviledge 
    setenv("WIRINGPI_GPIOMEM", "1", 1); // stops needing root on a recent system 
 
    int mode; 
    int time; 
 
    // Set up GPIO mode as output 
    wiringPiSetupGpio(); 
    pinMode(GREENLIGHT, PWM_OUTPUT); 
    pinMode(REDLIGHT, OUTPUT); 
 
    softPwmCreate(17, 1, 100); // Set PWM Channel along with range for green light 
 
    // Set both leds to off at start of program 
    softPwmWrite(REDLIGHT, 0); 
    pwmWrite(GREENLIGHT, 0); 
 
    for (;;) 
    { 
        mode = getchar(); // Request input from user 
 
        if (mode == '0') // Turn off leds 
        { 
            softPwmWrite(REDLIGHT, 0); // Turn off red lights 
            pwmWrite(GREENLIGHT, 0);   // Turn off green lights 
        } 
        else if (mode == '1') // Turn on leds 
        { 
            softPwmWrite(REDLIGHT, 100); // Turn on red light 
            pwmWrite(GREENLIGHT, 1024);  // Turn of green light 
        } 
        else if (mode == '2') 
        { 
            // Blinking with pattern of 2 time per second for both lights 
            // 2hz, 2x per second 
 
            blinkingOne(2); 
            // printf("How many time do you want the light to blink?\n"); 
            // scanf("%d", &time); 
            // blink1(time); 
        } 
        else if (mode == '3') 
        { 
            // Change pattern of red LED and green LED in different ways 
 
            blinkingTwo(); 
            // Red Lights : Blink 8 times per second, frequency 8hz 
            // Green light: Blink 2 times per second, with reduced brightness by 4 times. 
        } 
    } 
 
    return 0; 
}
