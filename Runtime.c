#include "Garbage_Collector.c"

#define STRING_TAG 0x10
#define IS_STRING(p) ((p & STRING_TAG) != 0)

word box_fixnum(word w){
  //printf("w: %u",w);
  return BOX(w);}
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
int is_string(Block * p) {return IS_STRING((word)(p->header));}

void setcar_ptr(Block *b, word val){b->car = val;}
void setcdr_ptr(Block *b, word val){b->cdr = val;}
void setcar(Block *b, word val){b->car = BOX(val);}
void setcdr(Block *b, word val){b->cdr = BOX(val);}

word getcar_ptr(Block *b) {return b->car;}
word getcdr_ptr(Block *b) {return b->cdr;}
word getcar(Block *b) {return UNBOX(b->car);}
word getcdr(Block *b) {return UNBOX(b->cdr);}

Block * string_cons(char * s){
  Block * n;
  GCPRO(n, nlocal);
  n = cons(BOX(*(s++)), (word)string_cons(s));
  n->header |= STRING_TAG;
  UNGCPRO(nlocal);
  return n;
}

int is_eq(word * a, word * b){ return a==b;}
int is_int_eq(word * a, word * b) {
  if(is_number(a) && is_number(b))
    return a==b;
  return 0;
}

int smaller(word a, word b){
  if(is_number(a) && is_number(b))
    return a<b;
  return 0;
}

//void test(word w){
//  GCPRO(w, wlocal);
//  printgc();
//  UNGCPRO(wlocal);
//}

/*
int main(){
  //add_root(0xF0);
  //remove_root();
  //test(0xF);
  //printgc();
  //printf("123: %u\n", box_fixnum(2));
  //printf("123: %u\n", unbox_fixnum(box_fixnum(2)));
  mem_init();
  printf("Begin\n");
  cons(1,0);
  printf("End\n");
  return 0;
}

*/
