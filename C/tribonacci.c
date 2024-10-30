#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {

    if (argc < 2) {
        exit(1);
    }

    int length;
    if (sscanf(argv[1], "%d", &length) != 1) {
        exit(1);
    }

    int prev_three = 1;
    int prev_two = 1;
    int prev_one = 1;
    for (int i = 0; i < length; i++) {
        if (i < 2) {
            printf("%d\n", prev_one);
            continue;
        }

        if (i == 2) {
            prev_one += prev_two;
            printf("%d\n", prev_one);
            continue;
        }
        
        int temp_one;
        temp_one =  prev_one;

        prev_one = prev_one + prev_two + prev_three;

        if (i > 3) {
            int temp_two;
            temp_two = prev_two;
            prev_two = temp_one;
            prev_three = temp_two;
        } 
        else {
            prev_two += prev_three;
        }
        printf("%d\n", prev_one);
    }

    return EXIT_SUCCESS;
}