#include <stdio.h>
#include <stdlib.h>

int recursion(int n) {
    if (n == 0) {
        return 2;
    }
    return 3 * n - 2 * recursion(n - 1) + 7;
}

int main(int argc, char *argv[]) {

    if (argc < 2) {
        exit(1);
    }

    int number;

    if (sscanf(argv[1], "%d", &number) != 1) {
        exit(1);
    }

    if (number < 0) {
        return EXIT_SUCCESS;
    }

    int answer = recursion(number);
    printf("%d\n", answer);

    return EXIT_SUCCESS;
}