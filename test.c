#include <stdio.h>
#include <time.h>
#include <conio.h>

void blink();
void delay(int number_of_seconds);

char t;

int main()
{

    unsigned char mode;

    for (;;)
    {
        mode = getchar();

        if (mode == '0')
        {
            printf("Off all lights \n");
        }
        else if (mode == '1')
        {
            printf("On both lights \n");
        }
        else if (mode == '2')
        {
            // Blink lights;
            do
            {
                blink();
                mode = getchar();
                delay(1000);

            } while (mode == '2');
        }
        else
        {
            // 3
        }
    }

    return 0;
}

void blink()
{
    printf("RED ON --- ");
    printf("GREEN ON \n");
    delay(1000);
    printf("RED OFF --- ");
    printf("GREEN OFF \n");
}

void delay(int number_of_seconds)
{
    // Converting time into milli_seconds
    int milli_seconds = 1000 * number_of_seconds;

    // Storing start time
    clock_t start_time = clock();

    // looping till required time is not achieved
    while (clock() < start_time + milli_seconds)
        ;
}
