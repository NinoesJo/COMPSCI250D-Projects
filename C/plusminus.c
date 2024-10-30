#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct HoopsPlayer {
    char name[64];
    int plus;
    int minus;
    int plusminus;
    struct HoopsPlayer* next;
};

void sortlist(struct HoopsPlayer **head) {
    int sorted = 0;

    while (!sorted) {
        struct HoopsPlayer* current = *head;
        struct HoopsPlayer* previous = NULL;
        sorted = 1;

        while (current != NULL && current->next != NULL) {
            struct HoopsPlayer* next = current->next;

            if (current->plusminus < next->plusminus || (current->plusminus == next->plusminus && strcmp(current->name, next->name) > 0)) {
                sorted = 0;

                if (previous != NULL) {
                    previous->next = next;
                } else {
                    *head = next;
                }

                current->next = next->next;
                next->next = current;
                current = next;

            } else {
                previous = current;
                current = next;
            }
        }
    }
}

int main(int argc, char* argv[]) {

    if (argc < 2) {
        printf("Need to add a text file\n");
        exit(1);
    }

    FILE *input = fopen(argv[1], "r");

    struct HoopsPlayer* head = NULL;

    while (1) {
        char name[64];
        int plus;
        int minus;
        int plusminus;

        fscanf(input, "%63s\n",name);
        int compar = strcmp(name, "DONE");
        if (compar == 0) {
            break;
        }
        fscanf(input, "%d\n",&plus);
        fscanf(input, "%d\n", &minus);
        plusminus = plus - minus;
        struct HoopsPlayer* newPlayer = (struct HoopsPlayer*)malloc(sizeof(struct HoopsPlayer));

        strcpy(newPlayer->name, name);
        newPlayer->plus = plus;
        newPlayer->minus = minus;
        newPlayer->plusminus = plusminus;
        newPlayer->next = head;
        head = newPlayer;
    }

    fclose(input);

    sortlist(&head);

    while (head != NULL) {
        printf("%s %d\n", head->name, head->plusminus);
        struct HoopsPlayer* temp = head->next;
        free(head);
        head = temp;
    }

    return EXIT_SUCCESS;
}