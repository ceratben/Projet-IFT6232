#include "Garbage_Collector.c"

#define STRING_TAG 0x10
#define IS_STRING(p) ((p & STRING_TAG) != 0)

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
  Block * n = cons(BOX(*(s++)), (word)string_cons(s));
  n->header |= STRING_TAG;
  return n;
}

int is_eq(word * a, word * b){ return a==b;}
int is_int_eq(word * a, word * b) {
  if(is_number(a) && is_number(b))
    return a==b;
  return 0;
}

void add_root(word * r){
  printf("In add_root\n");
  //printf("r: %p\n", r);

  if(!IS_POINTER((word) r)) return;

  // The add of the block is the add of the wagon.
  // Create a new list element for the root
  List * root = (List*) malloc(sizeof(List));
  if(root == NULL) return;

  printf("Root not null\n");
  root->cell = (Wagon *) r;

  // Add the root to pro_cell
  //pro_cell->next = root;
  root->next = pro_cell;
  pro_cell = root;
  //printf("r: %p\n", r);
  printf("End add_root\n");
}

void remove_root() {
  // Libère la racine
  printf("In remove_root\n");
  if(pro_cell == NULL) return;
  List * t = pro_cell->next;
  printf("In remove_root1\n");
  //free(pro_cell);
  printf("In remove_root2\n");
  // Pop
  pro_cell = t;
  printf("End remove_root\n");
}

/*int main(){
  add_root(0xF0);
  remove_root();
  return 0;
}
*/
