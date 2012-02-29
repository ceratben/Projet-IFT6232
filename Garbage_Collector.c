
#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>

// Definitions
typedef ssize_t word;
#define BLOCK_SIZE (3)

#define BOX(p) ((p)<<2 | 0x01)
#define UNBOX(p) ((p)>>2)
#define HEADERISE(p) ((p)<<2 | 0x03)


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

#define GCPRO( var_ref, local_name ) Pile local_name; local_name.content = &var_ref; local_name.previous = gcstack; gcstack = &local_name;
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
    if(mill != NULL){
      printf("%8.8p %8.8p %8.8p %8.8p %8.8p %8.8p\n",mill, mill->cell.header, mill->cell.car, mill->cell.cdr, mill->next, mill->previous);
      if(mill->next != NULL)
	mill = mill->next;
      else break;
    }
    else printf("NULL\n");
    
  }
  while(mill != free_mem);
}

void printgc(){
  Pile * mill = gcstack;
  
  // Headers
  printf("\nPrinting Roots: \n");
  printf("add        content    previous\n");

  do{
    if(mill != NULL){
      printf("%8.8p %8.8p %8.8p\n",mill, *(mill->content), mill->previous);
      if(mill->previous != NULL)
	mill = mill->previous;
      else break;
    }
    else printf("NULL\n");
  }
  while(mill != NULL);
}

void prettyPrint(){
  printGlobal();
  printgc();
  memPrint();
  printf("\n");
}

// Collection

void move(Wagon * y, Wagon * dest){
  if(y->next != NULL){
    y->next->previous = y->previous;
    y->previous->next = y->next;
  }
  y->previous = dest;
  y->next = dest->next;
  y->next->previous = y;
  dest->next = y;
}

void inner_copy(word * x){
  if(x == NULL) return;
  Wagon * y = (Wagon *) x;
  if(y == tospace) tospace = tospace->previous;
  else {
    if(y == fromspace) fromspace = fromspace->next;
    move(y, tospace);
  }
}

void forward(Block * x){
  if(IS_POINTER(x->header)) inner_copy((word *)x->header);
  else if (IS_HEADER(x->header)) {
    forward((Block *) &(x->car));
    forward((Block *) &(x->cdr));
  }
}

void flip(){
  printf("Begin Flip: \n");
  Wagon * temp = free_mem;
  fromspace = tospace;
  tospace = free_mem->previous;
  scan = free_mem->previous;

  //copy rootset
  Pile * GC_pro = gcstack;
  while(GC_pro != NULL){
    inner_copy((word *) *GC_pro->content);
    GC_pro = GC_pro->previous;
  }
  prettyPrint();
}

void scanner(){
  if(scan->previous != tospace){
    scan = scan->previous;
    forward(&(scan->cell));
  }
  else flip();
}

// Allocation

Wagon * mem_alloc(){
  Wagon * newBlock;
  scanner();

  if(free_mem->next == fromspace) 
    move((Wagon *) malloc(sizeof(Wagon)), free_mem);
  newBlock = free_mem;
  free_mem = free_mem->next;
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

// Methodes de librarie concernant l'allocation.
Wagon * object_allocate(int type, word val1, word val2){
  Wagon * w = mem_alloc();
  switch(type){
  case 0:
    // Une paire
    w->cell.header =  HEADERISE(0);
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

word box_fixnum(word w){return BOX(w);}
word unbox_fixnum(word w){return UNBOX(w);}

Block* cons(word car, word cdr){
  Wagon *w = object_allocate(0, car, cdr);
  return &(w->cell);
}

Block * cons_null(){
  return cons(0,0);
}

word null(){ return 0x0;}

int is_null(word * p) {return (p == NULL)?1:0;}
int is_pair(word * p) {return IS_HEADER((word)p);}
int is_number(word * p) {return IS_FIXNUM((word) p);}

void setcar_ptr(Block *b, word val){b->car = val;}
void setcdr_ptr(Block *b, word val){b->cdr = val;}
void setcar(Block *b, word val){b->car = BOX(val);}
void setcdr(Block *b, word val){b->cdr = BOX(val);}

word getcar_ptr(Block *b) {return b->car;}
word getcdr_ptr(Block *b) {return b->cdr;}
word getcar(Block *b) {return UNBOX(b->car);}
word getcdr(Block *b) {return UNBOX(b->cdr);}

// Tests
//Arbre arith
char * expr_str = "+1*39";
Wagon * Gen_Tree(){
  printf("\nBegin Gen_Tree\n");
  //prettyPrint();
  Wagon * tree = object_allocate(0, 0, 0);
  GCPRO(tree, tree2);
  
  if(*expr_str >= 48 && *expr_str <=57){
    //printf("In if: expr: %c, tree2.current: %u\n", *expr_str, &(tree->cell));
    tree->cell.header = HEADERISE((word)(*expr_str++));
    tree->cell.car = BOX(0);
    tree->cell.cdr = BOX(0);
  }
  else{
    //printf("In else: expr: %c\n", *expr_str);
    tree->cell.header = BOX(*expr_str++);
    // Initialise a 1 pour éviter des problèmes de scan.
    tree->cell.car = BOX(0);
    tree->cell.cdr = BOX(0); 
    tree->cell.car = (word)Gen_Tree();
    tree->cell.cdr = (word)Gen_Tree();
  }
  UNGCPRO(tree2);
  printf("End Gen_Tree \n\n");
  return tree;
}


// Eval tree
word evalTree(Wagon * tree){
  // Parcour l'arbre pour reconstituer l'expression
  if((word)tree == 1) return 0;
  word cur = UNBOX(tree->cell.header), car = tree->cell.car, cdr = tree->cell.cdr;

  // Si valeur, return valeur.
  //printf("Tree[0]: %d, %p \n", cur, &(tree->cell));
  if(cur>=48 && cur<=57) return (cur-48);
  // Si op: evalTree des enfants puis switch l'op sur les valeurs.
  else{
    //printf("Dans le else: car: %p, cdr: %p\n", tree->cell.car, tree->cell.cdr);
    word l = evalTree((Wagon *)((word *)tree->cell.car)), r = evalTree((Wagon *)((word *)tree->cell.cdr));
    //printf("l: %d, r: %d\n", l, r);
    switch(cur){
    case '*': return l*r;
    case '+': return l+r;
    default: return 0;
    }
  }
}

// Main
int main(){
  mem_init();
  printf("Mem Init Done\n\n");
  prettyPrint();
  Wagon * w1 = object_allocate(2, 32, 0);
  GCPRO(w1, t);
  //prettyPrint();
  Wagon * w2 = object_allocate(1, (word) w1, 0);
  GCPRO(w2, t2);
  //UNGCPRO(t);
  prettyPrint();
  Wagon * w3 = object_allocate(2, 7, 0);
  prettyPrint();
  Wagon * w4 = object_allocate(2, 8, 0);
  prettyPrint();
  Wagon * w5 = object_allocate(2, 9, 0);
  prettyPrint();
  Wagon * w6 = object_allocate(2, 10, 0);
  prettyPrint();
  UNGCPRO(t);
  printf("It runs!\n");
  
  printf("\nStarting Gen_Tree\n");
  Wagon * tree = Gen_Tree();
  GCPRO(tree, t3);
  //prettyPrint();
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  w6 = object_allocate(2, 10, 0);
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  w6 = object_allocate(2, 10, 0);
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  w6 = object_allocate(2, 10, 0);
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  w6 = object_allocate(2, 10, 0);
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  //prettyPrint();
  w6 = object_allocate(2, 10, 0);
  //prettyPrint();
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  w6 = object_allocate(2, 10, 0);
  prettyPrint();
  printf("La valeur de l'arbre est: %d\n", evalTree(tree));
  
  return 0;
}
