CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -std=c11
PREFIX ?= /usr/local
all: __APP_NAME__
__APP_NAME__: main.c
	$(CC) $(CFLAGS) -o $@ $<
install: __APP_NAME__
	install -Dm755 __APP_NAME__ $(PREFIX)/bin/__APP_NAME__
clean:
	rm -f __APP_NAME__
