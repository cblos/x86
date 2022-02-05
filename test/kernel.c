#define WHITE_TXT 0x07 /* Light gray on black text */

void clean() {
    char *vidmem = (char *) 0xB8000;
    unsigned int i = 0;

    while(i < (80 * 25 * 2)) {
        vidmem[i]= ' ';
        i++;
        vidmem[i] = WHITE_TXT;
        i++;
    };
};

unsigned int printf(char *message, unsigned int line) {
    char *vidmem = (char *) 0xb8000;
    unsigned int i = 0;

    i = line * 80 * 2;

    while(*message != 0) {
        // Check for a newline
        if (*message == '\n') {
            line++;
            i = line * 80 * 2;
            *message++;
        } else {
            vidmem[i] =* message;
            *message++;
            i++;
            vidmem[i] = WHITE_TXT;
            i++;
        };
    };

    return 1;
}

void _main () {
    clean();
    printf("Hello World!", 0);
};
