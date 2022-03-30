#define SIZE 5
#define VERIFY_PARTITION 
//#define VERIFY_SORT
#define ELEMENT_TYPE int
#define BORNE_INF 0
#define BORNE_SUP 9

// Tableau variable globale
ELEMENT_TYPE tab[SIZE];
// Canal variable globale, debut et fin du quicksort
chan canal_global = [0] of {byte}

proctype quicksort(chan canal_param; int low, high) 
{   
    // Initialisation canal local
    chan canal_local = [0] of {int}
    int p;
    if
    :: ((low >= 0) && (high >= 0) && (low < high)) ->
        // Partition 
        run partition(canal_local, low, high);
        // Récupération du p grâce au canal de partition
        canal_local?p;
       
        run quicksort(canal_local, low, p-1);
        // Bloquage grâce au canal pour ne pas faire les deux quicksort en même temp
        canal_local?_;
        run quicksort(canal_local, p+1, high);
        // Debloquage grâce au canal
        canal_local?_;
    :: else
    fi
    canal_param!0;
}

// Fonction de partition
proctype partition(chan canal_param; int lo, hi) 
{
    int pivot,tmp,j;
    short i = lo -1;
    pivot = tab[hi];
    for (j : lo .. hi) {
        if
        :: tab[j] <= pivot -> 
        i = i+1;
        // Swap
        tmp = tab[j];
        tab[j] = tab[i];
        tab[i] = tmp;
        :: else
        fi
    }
    //-----------------VERIFY_PARTITION------------------
    #ifdef VERIFY_PARTITION
        printf("VERIFY_PARTITION pivot:%d -> ",i);
        do
        :: i == 0 ->
            for (j : i .. hi-1) {
                assert(tab[i] <= tab[j+1]);
            };
            printf("ok\n");
            break;
        :: i == SIZE-1 -> 
            for (j : i .. lo+1) {
                assert(tab[i] >= tab[j-1]);
            };
            printf("ok\n");
            break;
        :: else -> 
            for (j : i .. hi-1) {
                assert(tab[i] <= tab[j+1]);
            };
            for (j : i .. lo+1) {
                assert(tab[i] >= tab[j-1]);
            }
            printf("ok\n");
            break;
        od
    #endif
    // --------------------------------------------
    // Envoie du pivot au quick sort
    canal_param!i;
}

proctype random() 
{
    // Génération du tableau aléatoire
    printf("Génération du tableau aléatoire ...");
    int j;
    ELEMENT_TYPE x;
    for (j : 0 .. SIZE-1) {
        select(x : BORNE_INF .. BORNE_SUP);
        tab[j] = x;
    }
    printf("tab[");
    for(j : 0 .. SIZE-1) {
        printf("%d",tab[j]);
    }
    printf("];\n\n");
    canal_global!0;
}

// Initialisation {init}
init 
{
    // Fonction de génération aléatoire
    run random();
    canal_global?_;
    // Lancement du quick-sort
    printf("Lancement du quicksort ...\n\n");
    run quicksort(canal_global, 0, SIZE-1);
    canal_global?_;
    // Vérification du tri
    //----------------VERIFY_SORT-------------------
    #ifdef VERIFY_SORT
        printf("VERIFY_SORT !\n\n");
        int h;
        for(h : 1 .. SIZE-1) {
            assert(tab[h] >= tab[h-1]);
        }
    #endif
    //----------------------------------------------
    // Affichage tableau trié
    printf("Tableau après tri : tab[");
    int b;
    for(b : 0 .. SIZE-1) {
        printf("%d",tab[b]);
    }
    printf("];\n\n");
}
