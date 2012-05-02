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

void start(){mem_init();}


/* Block * make_closure(word * fun, word * env) { */

/*   Block * newEnv, * c; */

/*   // On fait une copie de env. */

/*   // On cons la fun et la copie de env */

/*   return NULL; */
/* } */
// Chainer a l'envers
void add_root(word * r){
  // The add of the block is the add of the wagon.
  // Create a new list element for the root
  List * root = (List*) malloc(sizeof(List));
  if(root == NULL) return;
  root->cell = (Wagon *) r;

  // Add the root to pro_cell
  //pro_cell->next = root;
  root->next = pro_cell;
  pro_cell = root;
}

void remove_root() {
  // Libère la racine
  List * t = pro_cell->next;
  free(pro_cell);
  // Pop
  pro_cell = t;
}
