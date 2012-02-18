#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>

// Definitions
typedef ssize_t word;
#define BLOCK_SIZE (3)

#define BOX(p) ((p)<<1 | 0x01)
#define UNBOX(p) ((p)>>1)
#define HEADERISE(p) ((p)<<2 | 0x02)


#define IS_POINTER(p) ((p & 0x01) == 0)
#define IS_FIXNUM(p) ((p & 0x03) == 1)
#define IS_HEADER(p) ((p & 0x03) == 3)

typedef struct block {
  word header;
  word car;
  word cdr;
} Block;

typedef struct wagon {
  Block cell;
  struct wagon * next;
  struct wagon * previous;
} Wagon;

typedef struct pile{
  struct pile * previous;
  struct wagon ** content; 
} Pile;

#define GCPRO( var_ref, local_name ) Pile local_name; local_name.current = &var_ref; local_name.previous = gcstack; gcstack = &local_name;
#define UNGCPRO(local_name) ( gcstack = local_name.previous )

// Global Vars

static Wagon *fromspace=NULL, *tospace=NULL, *scan=NULL, *free_mem=NULL;
static Pile *gcstack=NULL;

// Pretty print
void printGlobal(){
  printf("\nPrinting Globals: \n");
  printf("    fromspace: %8.8p\n    tospace:   %8.8p\n    scan:      %8.8p\n    free_mem:  %8.8p\n", fromspace, tospace, scan, free_mem);
}
void memPrint(){
  Wagon * mill = free_mem;
  
  // Headers
  printf("\nPrinting Memory: \n");
  printf("add        header     car        cdr        next       previous\n");

  do{
    if(mill != NULL)
      printf("%8.8p %8.8p %8.8p %8.8p %8.8p %8.8p\n",mill, mill->cell.header, mill->cell.car, mill->cell.cdr, mill->next, mill->previous);
    else printf("NULL\n");
    if(mill->next != NULL)
      mill = mill->next;
    else break;
  }
  while(mill != free_mem);
}

void prettyPrint(){
  printGlobal();
  memPrint();
}

// Collection

void inner_copy(word * x){
  if(x == NULL) return;
  Wagon * y = (Wagon *) x;
  y->next = tospace;
  y->previous = tospace->previous;
  y->previous->next = y;
  tospace->previous = y;
}

void forward(Block * x){
  if(IS_POINTER(x->header)) inner_copy((word *)x->header);
  else if (IS_HEADER(x->header)) {
    forward((Block *) &(x->car));
    forward((Block *) &(x->cdr));
  }
}

void scanner();
void flip(){
  printf("Begin Flip: \n");
  Wagon * temp = free_mem;
  free_mem = scan;
  scan = temp;
  temp = fromspace;
  fromspace = tospace;
  tospace = temp;

  //copy rootset
  Pile * GC_pro = gcstack;
  while(GC_pro != NULL){
    forward(&((*(GC_pro->content))->cell));
    GC_pro = GC_pro->previous;
  }
  printf("Flip Done: \n");
}

void scanner(){
  printf("Begin Scan: %p\n", scan);
  if(scan != tospace){
    printf("Scan in IF: \n");
    forward(&(scan->cell));
    printf("Scan Forward: \n");
    scan = scan->previous;
  }
  else flip();
  printf("Scan Done\n");
}

// Allocation
Wagon * mem_alloc(){
  Wagon * newBlock;
  // Do a quanta of collection here:
  scanner();

  // Si il reste un wagon free. On le retourne
  if(free_mem != NULL && free_mem->next != fromspace) {
    printf("In if\n");
    newBlock = free_mem;
    free_mem = free_mem->next;
    return newBlock;
  }
  // Si il ne reste plus rien de free, on ajoute un block.
  printf("In else\n");
  newBlock = (Wagon *) malloc(sizeof( Wagon ));
  if(newBlock == NULL) exit(0);
  newBlock->next = fromspace;

  if(fromspace != NULL){
    newBlock->previous = fromspace->previous;
    if(fromspace->previous != NULL) fromspace->previous->next = newBlock;
    fromspace->previous = newBlock;
  }
  else newBlock->previous = NULL;
  free_mem = newBlock;
  return newBlock;
}

// Initialise la memoire avec 2 blocs.
/*
  +-------------+              +-------------+
->|             |------------->|             |---...
--|             |<-------------|             |<--...
  +-------------+              +-------------+
  |                                        
free                                  
from				   
  to
scan
*/

void mem_init(){
  Wagon * temp1 = (Wagon *) malloc(sizeof(Wagon));
  Wagon * temp2 = (Wagon *) malloc(sizeof(Wagon));
  if(temp1 == NULL || temp2 == NULL) exit(0);

  free_mem = temp1;
  fromspace = temp1;
  tospace = temp1;
  scan = temp1;
  
  temp2->next = free_mem;
  temp2->previous = free_mem;

  free_mem->next = temp2;
  free_mem->previous = temp2;
}


Wagon * object_allocate(int type, word val1, word val2){
  Wagon * w = mem_alloc();
  switch(type){
  case 0:
    // Une paire
    w->cell.header =  HEADERISE(BOX(0));
    w->cell.car = val1;
    w->cell.cdr = val2;
    break;
  case 1:
    // un pointeur
    w->cell.header = val1;
    w->cell.car = BOX(0);
    w->cell.cdr = BOX(0);
    break;
  case 2:
    // un fixnum
    w->cell.header = BOX(val1);
    w->cell.car = BOX(0);
    w->cell.cdr = BOX(0);
    break;
  }
  return w;
}

// Main

int main(){
  mem_init();
  printf("Mem Init Done\n\n");
  prettyPrint();
  Wagon * w1 = object_allocate(1, 32, 0);
  Wagon * w2 = object_allocate(1, (word) w1, 0);
  prettyPrint();
  printf("It runs!\n");
  return 0;
}
