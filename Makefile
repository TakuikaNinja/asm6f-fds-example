GAME=example
FORMAT=fds
OUTPUT=$(GAME).$(FORMAT)
ASSEMBLER=asm6f
FLAGS=-n -c -L -m

all: clean $(OUTPUT)

$(OUTPUT):
	$(ASSEMBLER) $(GAME).asm $(FLAGS) $(OUTPUT)

.PHONY: clean

clean:
	rm -f *.lst $(OUTPUT) *.nl *.mlb *.cdl

