#include <wiringPi.h>
#include <softPwm.h>
#include <stdio.h>
#include <stdlib.h>

// Definition
#define REDLIGHT 17   /*Redlight on PIN 17*/
#define GREENLIGHT 18 /*Greenlight on PIN 18*/

// Function prototype
void blinkingOne();
void blinkingTwo();

void blinkingOne()
{
    for (int j = 0; j <= 2; j++) // loop if j <= 2, with j+1 increment starting from 0
    {
        // 0-1024 value range for pwmWrite intensity/brightness
        // 0-100 value range for softPwmWrite intensity/brightness
        pwmWrite(GREENLIGHT, 1024);  // writes value 1024 to pwn register for GREENLIGHT/PIN 18 to turn it on
        softPwmWrite(REDLIGHT, 100); // writes pwn value for REDLIGHT/PIN 17 to 100 to turn it on
        delay(250);                  // wait 0.25s
        pwmWrite(GREENLIGHT, 0);     // writes value 0 to pwn register for GREENLIGHT to turn it off
        softPwmWrite(REDLIGHT, 0);   // writes pwn value for REDLIGHT to 100 to turn it off
        delay(250);                  // wait 0.25s
    }
}

void blinkingTwo()
{
    pwmWrite(GREENLIGHT, 0);
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
    pwmWrite(GREENLIGHT, 256);
}

int main()
{
    // Give sudo priviledge
    setenv("WIRINGPI_GPIOMEM", "1", 1); // stops needing root on a recent system

    int mode;
    int time;

    // Set up GPIO mode as output
    wiringPiSetupGpio();             // initialises wiringPi and assumes that the calling program is going to be using the wiringPi pin numbering scheme
    pinMode(GREENLIGHT, PWM_OUTPUT); // set GREENLIGHT to PWN_OUTPUT mode
    pinMode(REDLIGHT, OUTPUT);       // set REDLIGHT to OUTPUT mode

    softPwmCreate(17, 1, 100); // Set PWM Channel along with range for green light

    softPwmWrite(REDLIGHT, 0); // turn off red light
    pwmWrite(GREENLIGHT, 0);   // turn off green light

    for (;;)
    {
        mode = getchar(); // request input from user

        if (mode == '0') // turn off leds
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

            blinkingOne();
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
