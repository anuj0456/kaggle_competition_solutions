/*
 * Marek Cygan, Marcin Mucha
 * 01.2014
 * Packing Santa's Sleigh
 */

#include <thread>    
#include <unistd.h>
#include <cassert>
#include <cstdio>
#include <iostream>
#include <algorithm>
#include <set>
#include <map>
#include <stack>
#include <list>
#include <queue>
#include <deque>
#include <cctype>
#include <string>
#include <vector>
#include <sstream>
#include <iterator>
#include <numeric>
#include <cmath>
using namespace std;

#ifdef VISUALIZE
#include "CImg.h"
using namespace cimg_library;
#endif

typedef vector <int > VI;
typedef vector < VI > VVI;
typedef long long LL;
typedef vector < LL > VLL;
typedef vector < double > VD;
typedef vector < string > VS;
typedef pair<int,int> PII;
typedef vector <PII> VPII;
typedef istringstream ISS;

#define ALL(x) x.begin(),x.end()
#define REP(i,n) for (int i=0; i<(n); ++i)
#define FOR(var,pocz,koniec) for (int var=(pocz); var<=(koniec); ++var)
#define FORD(var,pocz,koniec) for (int var=(pocz); var>=(koniec); --var)
#define FOREACH(it, X) for(__typeof((X).begin()) it = (X).begin(); it != (X).end(); ++it)
#define PB push_back
#define PF push_front
#define MP(a,b) make_pair(a,b)
#define ST first
#define ND second
#define SIZE(x) (int)x.size()

const int N = 1001 * 1001;
const int R = 1000000;
int presents[N][3];
int n = 1000000; 
int random_numbers[R];

const int BRANCHING_1 = 4; 
const int BRANCHING_2 = 8; 
const int BORDER_SMALL = 699000;
const int BORDER_STOP_UNDER = 698500;
const int POOL_SIZE = 40;
const int NUM_THREADS = 20; 
const int RANDOM_ROTATIONS = 30;
const int REFLECTIONS = 2;
const int LIFTED_BOXES = 15;
const int LIFTED_TRESHOLD = 5;

inline int notintersect(int a,int b,int c,int d) {
  return b < c || d < a;
}

struct Box {
  int x,y,z; //corner
  int a,b,c; //dimensions
  int border, dir; 
  int id;
  Box(int _x,int _y, int _z, int _a,int _b, int _c, int _id, int _border, int _dir) {
    x=_x; y=_y; z=_z; a=_a; b=_b; c=_c; id=_id; border=_border; dir=_dir;
  }
};

struct Skyline {
  vector<pair<PII,int> > s;
  int D;

  Skyline(int _D) {
    D = _D;
    s.PB(MP(MP(0,D-1), 0));
  }

  void update(int l, int r, int top) {
    l = max(0, l); r = min(r,D-1);
    vector<pair<PII,int> > ns;
    ns.reserve(SIZE(s)+3);
    FOREACH(it, s) {
      int a = it->ST.ST;
      int b = it->ST.ND;
      if (b < l || a > r) {
        ns.PB(*it);
        continue;
      }
      if (a < l) ns.PB(MP(MP(a,l-1), it->ND));
      if (r < b) ns.PB(MP(MP(r+1,b), it->ND));
    }
    ns.PB(MP(MP(l,r), top));
    swap(s, ns);
  }

  //area - area over the inserted rectangle
  int find_top_with_area(int l, int r, int &area) {
    l = max(0, l); r = min(r,D-1);
    area = 0;

    int res = 0;
    FOREACH(it, s) {
      int a = max(l,it->ST.ST);
      int b = min(r,it->ST.ND);

      if (a > b) continue; 
      area += (b-a+1) * it->ND;
      res = max(res, it->ND);
    }
    area = (r-l+1)*res - area;
    return res;
  }

  //shift - how far we need to go to change the resulted value
  int find_top_with_shift(int l, int r, int dir, int &shift) const {
    if (l >= D || r < 0) return 0;

    l = max(0, l); 
    r = min(r,D-1);

    int res = 0;
    FOREACH(it, s) {
      int a = max(l,it->ST.ST);
      int b = min(r,it->ST.ND);
      if (a > b) continue;

      if (dir == 1) {
        shift = min(shift, b-l + 1);
      } else {
        shift = min(shift, r-a + 1); 
      }
      res = max(res, it->ND);
    }
    return res;
  }
};

inline int between(int a,int b,int c){
  return a >= b && a <= c;
}

struct Cube{
  int a, b, c;
  int id;
  Cube(int _a, int _b, int _c, int _id) {
    a=_a; b=_b; c=_c; id=_id;
  }
};

bool operator<(const Cube &x, const Cube &y) {
  if (x.a != y.a) return x.a < y.a;
  if (x.b != y.b) return x.b < y.b;
  if (x.c != y.c) return x.c < y.c;
  return x.id < y.id;
}

VPII gen_subsets(VI v) {
  VPII res;
  int k = SIZE(v);
  int ile = 1<<k;
  res.reserve(ile);
  REP(mask,ile) {
    int s = 0;
    REP(i,k) if ((1<<i) & mask) s += v[i];
    res.PB(MP(s, mask));
  }
  return res;
}

int solve_subset_sum(const VI &v, int A) {
  int k = SIZE(v);
  VI v1, v2;
  REP(i,SIZE(v)) if (i < k/2) v1.PB(v[i]);
  else v2.PB(v[i]);

  VPII subsets1, subsets2;
  subsets1 = gen_subsets(v1);
  subsets2 = gen_subsets(v2);
  sort(ALL(subsets1));
  sort(ALL(subsets2));

  int j = SIZE(subsets2)-1;
  int best_mask = 0;
  int best_sum = 0;
  REP(i,SIZE(subsets1)) {
    int x = subsets1[i].ST;
    while (j >= 0 && subsets2[j].ST+x > A) j--;
    while (j > 0 && subsets2[j-1].ST == subsets2[j].ST) j--;
    if (j >= 0) {
      int nmask = subsets1[i].ND + (subsets2[j].ND << (k/2));
      int nsum = subsets2[j].ST + x;
      if (nsum > best_sum || (nsum == best_sum && nmask < best_mask)) {
        best_sum = nsum;
        best_mask = nmask;
      }
    }
  }
  return best_mask;
}

// packing is in a/b dimensions of cubes
// if returns 1, then last_packing contains the packing
int can_pack_2d_first_fit(Skyline skyline, const Skyline &bottom_skyline, vector<Cube> v, int A, int B, int x_offset, int y_offset, int z_offset, int optimize_subset_sum, vector<Box> &last_packing, int border = 0, int dir = 1){
  vector<Box> packing;
  int pos = 0;
  int nawroty = 0;
  VI vis(SIZE(v), 0);
  while (pos < SIZE(v)) {
    if (optimize_subset_sum){
      VI ktore;
      int suma = (dir == 1 ? border : 999-border);
      int ni = SIZE(v);
      FOR(i,pos,SIZE(v)-1) if (vis[i] == 0) {
        if (suma + v[i].b <= A) {
          suma += v[i].b;
          ktore.PB(i);
        } else {
          ni = i;
          break;
        }
      }
      VI cand;
      while (ni < SIZE(v) && SIZE(cand) < BRANCHING_1) { 
        if (vis[ni] == 0) cand.PB(ni);
        ni++;
      }
      if (!cand.empty()) {
        while (SIZE(cand) < BRANCHING_2 && SIZE(ktore) > 0) { 
          cand.PB(ktore.back());
          suma -= v[ktore.back()].b;
          ktore.pop_back();
        }
        sort(ALL(cand));

        VI subset_sum;
        FOREACH(it, cand) subset_sum.PB(v[*it].b);
        int best_mask = solve_subset_sum(subset_sum, A-suma);
        REP(i,SIZE(cand)) if ((1<<i) & best_mask) ktore.PB(cand[i]);
      }

      VPII pom;
      FOREACH(it, ktore) pom.PB(MP(-v[*it].a,*it));
      ktore.clear();
      FOREACH(it, pom) ktore.PB(it->ND);

      FOREACH(it, ktore) {
        int shift = 1000;
        int which = *it;
        int l = border;
        int r = border + dir * (v[which].b-1);
        int top = 0;
        if (l > r) swap(l,r);
        top = skyline.find_top_with_shift(l, r, dir, shift);
        int bottom = min(B, 1000-bottom_skyline.find_top_with_shift(l, r, dir, shift)); 
        if (top + v[which].a > bottom || !between(border + dir*(v[which].b-1),0,A-1)){
          break;
        }
        nawroty = 0;
        vis[which] = 1;
        packing.PB(Box(l,top,0,v[which].b,v[which].a,v[which].c,v[which].id,border + dir * v[which].b,dir));

        skyline.update(l,r,top+v[which].a);
        border += dir * v[which].b;
      }
    }

    while (pos < SIZE(v)) {
      if (vis[pos] == 1) {
        pos++;
        continue;
      }

      int which = -1;
      FOR(i,pos,SIZE(v)-1) if (vis[i]==0 && between(border + dir * (v[i].b-1), 0, A-1)) {
        which = i;
        break;
      }
      if (which != -1) {
        while (true) {
          int ok = 0;
          int shift = 1000;
          REP(foo,2) {
            int l = border;
            int r = border + dir * (v[which].b-1);
            int top = 0;
            if (l > r) swap(l,r);
            top = skyline.find_top_with_shift(l, r, dir, shift);
            int bottom = min(B, 1000-bottom_skyline.find_top_with_shift(l, r, dir, shift)); 
            if (top+v[which].a > bottom || !between(border+dir * (v[which].b-1),0,A-1)){
              swap(v[which].a, v[which].b);
              continue;
            }
            ok = 1;
            nawroty = 0;
            vis[which] = 1;
            packing.PB(Box(l,top,0,v[which].b,v[which].a,v[which].c,v[which].id, border + dir * v[which].b,dir));

            skyline.update(l,r,top+v[which].a);
            border += dir * v[which].b;
            break;
          }
          if (!ok){
            border += dir * shift;
            if (border >= A || border < 0){
              if (nawroty > 0) return 0;
              nawroty++;
              border = dir == 1 ? A-1 : 0;
              dir = -dir;
            }
          } else break;
        }
      } else {
        if (dir == 1) border = A-1;
        else border = 0;
        dir = -dir;
        break;
      }
    }
  }

  assert(x_offset >= 0);
  last_packing = packing;
  FOREACH(it, last_packing) {
    it->x += x_offset;
    it->y += y_offset;
    it->z += z_offset;
  }
  return 1;
}

/* finds upper bound on new position based on area */
int find_upper_bound(int r, int height, int AREA) {
  int area = 0;
  while (r < n) {
    int a = presents[r][0] * presents[r][1] * presents[r][2];
    if (presents[r][2] <= height) a /= presents[r][2];
    else if (presents[r][1] <= height) a /= presents[r][1];
    else if (presents[r][0] <= height) a /= presents[r][0];
    else break;
    if (area + a > AREA) {
      break;
    }
    area += a;
    r++;
  }
  return r;
}

inline int give_area(int i, int h) {
  int a = presents[i][0];
  int b = presents[i][1];
  int c = presents[i][2];
  if (c <= h) return a * b;
  if (b <= h) return a * c;
  if (a <= h) return b * c;
  return 1001 * 1001;
}

inline Cube give_cube(int i, int h) {
  int a = presents[i][0];
  int b = presents[i][1];
  int c = presents[i][2];
  Cube cube(0,0,0,0);
  if (c <= h) cube = Cube(a,b,c,i);
  else if (b <= h) cube = Cube(a,c,b,i);
  else if (a <= h) cube = Cube(b,c,a,i);
  return cube;
}

/* v contains positions */
int can_pack_first_fit_wrapper(const Skyline &skyline, const Skyline &bottom_skyline, VI vv, int A, int B, int h, int optimize_subset_sum, vector<Box> &last_packing, int randomize, int border = 0, int dir = 1) {
  vector<Cube> v; 
  FOREACH(it, vv) {
    int i = *it;
    if (presents[i][0] > h) return 0;
    v.PB(give_cube(i,h));
  }

  FOREACH(it, v) if (it->a < it->b) swap(it->a,it->b);
  if (randomize) {
    int pos = randomize * 1007;
    VI ktore;
    REP(i,SIZE(v)) if (v[i].a > 30 || v[i].b > 30) {
      ktore.PB(i);
    }
    int ile = random_numbers[pos++] % min(6, SIZE(ktore));
    REP(foo, ile) {
      int i = random_numbers[pos++] % SIZE(ktore);
      swap(v[ktore[i]].a, v[ktore[i]].b);
    }
  }
  sort(ALL(v));
  reverse(ALL(v)); 
  return can_pack_2d_first_fit(skyline, bottom_skyline, v, A, B, 0, 0, 0, optimize_subset_sum, last_packing, border, dir);
}

//returns h2 in case of failure
//in case of success returns smallest level at which 
int extend_one_box(int A, int B, int a,int b,int c,int h2, const vector<Box> &lower, int &x_offset, int &y_offset, int flat_only = 0) {
  if (c > h2) return h2;
  x_offset = A; y_offset = B;

  int l = 0;
  int r = flat_only ? 1 : h2-c+1;
  while (l < r) {
    int m = (l+r)/2;
    int ok = 0;

    vector<pair<PII,PII> > v;
    v.reserve(2 * SIZE(lower) + 1);
    v.PB(MP(MP(0,1),MP(B,B)));

    FOREACH(it, lower) if (it->z+it->c > m){
      int b1 = max(0, it->y-(b-1));
      int b2 = min(B-1, it->y+it->b-1);
      v.PB(MP(MP(it->x-(a-1),1), MP(b1,b2)));
      v.PB(MP(MP(it->x+it->a,-1), MP(b1,b2)));
    }

    sort(ALL(v));

    int i = 0;
    VPII segments;
    segments.PB(MP(B, B));
    while (!ok && i < SIZE(v)) {
      int x = v[i].ST.ST;
      while (i < SIZE(v) && v[i].ST.ST == x) {
        if (v[i].ST.ND == 1) segments.PB(v[i].ND);
        else {
          int found = 0;
          FOREACH(it, segments) if (*it == v[i].ND) {
            swap(*it, segments.back());
            segments.pop_back();
            found = 1;
            break;
          }
          assert(found);
        }
        i++;
      }
      if (x >= 0 && x+a <= A) {
        sort(ALL(segments));
        int cand = 0;
        FOREACH(it, segments) {
          if (it->ST > cand) {
            if (cand + b <= B) {
              ok = 1;
              x_offset = x;
              y_offset = cand;
            }
            break;
          } else cand = max(cand, it->ND+1);
        }
      }
    }

    if (ok) {
      r = m;
    } else {
      l = m+1;
    }
  }
  if (l + c > h2) return h2;
  else{
    if (flat_only == 0 || l == 0) {
      FOREACH(it, lower) assert(it->c+it->z <= l || notintersect(it->x,it->x+it->a-1,x_offset,x_offset+a-1) || notintersect(it->y,it->y+it->b-1,y_offset,y_offset+b-1));
      assert(x_offset + a <= A && y_offset + b <= B);
    }
    return l;
  }
}

inline Box extend_one_box_wrapper(int A, int B, int pos, int h2, int min_z_offset, const vector<Box> &lower, int flat_only = 0) {
  Box b(-1,-1,-1,-1,-1,-1,-1,-1,-1);
  int z_offset = h2; //infty
  int k0 = -1;

  if (flat_only) {
    if (presents[pos][2] <= h2) k0 = 2;
    else if (presents[pos][1] <= h2) k0 = 1;
    else if (presents[pos][0] <= h2) k0 = 0;
    else return b;
  }
  REP(i,3) if (i != k0) REP(j,3) if (j != i && j != k0) REP(k,3) if ((k0 == -1 || k==k0) && i != k && j != k && presents[pos][i] <= A && presents[pos][j] <= B && min_z_offset + presents[pos][k] <= h2) {
    int cand_x = 1000, cand_y = 1000;
    int cand = extend_one_box(A, B, presents[pos][i], presents[pos][j], presents[pos][k], h2, lower, cand_x, cand_y, flat_only);
    if (flat_only && cand > 0) continue;
    cand = max(cand, min_z_offset);
    if (cand + presents[pos][k] > h2) cand = h2;
    if (cand < z_offset || (cand == z_offset && MP(cand_y, cand_x) <= MP(b.y, b.x))) {
      z_offset = cand;
      b = Box(cand_x, cand_y, z_offset, presents[pos][i], presents[pos][j], presents[pos][k], pos, -2, -2);
    }
  }
  return b;
}

void add_boxes_under(vector<Box> *under, vector<Box> &last_packing, const VI &killed, const vector<pair<int,Cube> > &empty) {
  REP(i,SIZE(empty)){
    int found = 0;
    FOREACH(it, last_packing) if (it->id == empty[i].ND.id) {
      if (it->a != empty[i].ND.a) {
        assert(empty[i].ND.a == it->b && empty[i].ND.b == it->a);
        //rotate
        FOREACH(it2, under[i]) {
          swap(it2->a, it2->b);
          swap(it2->x, it2->y);
        }
      }
      found = 1;
      it->z = killed[i];
      it->dir = it->border = -4; 
      FOREACH(it2, under[i]) {
        it2->x += it->x;
        it2->y += it->y;
        assert(it2->z == 0);
      }
      break;
    }
    assert(found == 1);
  }
  REP(i,SIZE(empty)) FOREACH(it, under[i]) last_packing.PB(*it);
}

int can_pack_two_regions(const Skyline &skyline, const Skyline &bottom_skyline, int start, int end, int A, int B1, int B2, int h1, int h2, int topboxes, int longsnake, vector<Box> &last_packing) {
  VI big, small;
  set<int> used;
  vector<pair<pair<double,int> ,PII> > v;
  vector<pair<int,Cube> > empty;
  int max_lift = h2;
  VPII unused;
  vector<Box> under[LIFTED_BOXES];
  FORD(i,end,start) if (start < BORDER_STOP_UNDER && end-i < LIFTED_BOXES && max_lift >= LIFTED_TRESHOLD) {
    int a = presents[i][0];
    Cube c(-1,-1,-1,-1);
    if (a > h1) return 0;
    if (a > h2 || give_area(i, h1) * h1 <= give_area(i, h2) * h2) {
      c = give_cube(i, h1);
      c.c = min(h1 - c.c, max_lift);
      if (c.c >= LIFTED_TRESHOLD) big.PB(i);
    } else {
      c = give_cube(i, h2);
      c.c = min(h2 - c.c, max_lift);
      if (c.c >= LIFTED_TRESHOLD) small.PB(i);
    }
    max_lift = min(max_lift, c.c);
    if (max_lift < LIFTED_TRESHOLD) {
      unused.PB(MP(presents[i][0] * presents[i][1] * presents[i][2], i));
      continue;
    }
    empty.PB(MP(c.c, c));
    used.insert(i);
  } else {
    unused.PB(MP(presents[i][0] * presents[i][1] * presents[i][2], i));
  }
  sort(ALL(empty));
  sort(ALL(unused)); reverse(ALL(unused));
  VI killed(SIZE(empty), 0);
  FOREACH(it, unused) {
    REP(i,SIZE(empty)) if (it->ST <= empty[i].ND.a * empty[i].ND.b * empty[i].ND.c) {
      Box b = extend_one_box_wrapper(empty[i].ND.a, empty[i].ND.b, it->ND, empty[i].ND.c, 0, under[i], 1);
      if (b.a <= 0) continue;
      assert(b.id == it->ND);
      killed[i] = max(killed[i], b.c);
      used.insert(it->ND);
      b.border = b.dir = -3;
      under[i].PB(b);
      break;
    }
  }

  int min_z_offset = 0;
  FOR(i,start,end) if (end-i < SIZE(empty)) {
    int which = -1;
    REP(j,SIZE(empty)) if (empty[j].ND.id == i) {
      which = j;
      break;
    }
    assert(which >= 0);
    killed[which] = max(killed[which], min_z_offset);
    min_z_offset = killed[which];
  }

  FOR(i,start,end) if (!used.count(i)) {
    int a = presents[i][0];
    if (a > h1) return 0;
    if (a > h2) {
      big.PB(i);
    } else {
      int v1 = give_area(i, h1) * h1;
      int v2 = give_area(i, h2) * h2;
      v.PB(MP(MP((double)v1/v2,i), MP(v1,v2)));
    }
  }
  if (start < BORDER_SMALL && SIZE(big) > topboxes && topboxes < 30 && topboxes > 1) return 0;
  sort(ALL(v));

  if (longsnake) {
    REP(i,SIZE(v)) if (SIZE(big) < topboxes) {
      big.PB(v[i].ST.ND);
    } else {
      small.PB(v[i].ST.ND);
    }
    VPII order;
    vector<Cube> cubes;
    FOREACH(it, big) {
      cubes.PB(give_cube(*it,h1));
    }
    FOREACH(it, small) {
      cubes.PB(give_cube(*it,h2));
    }
    FOREACH(it, cubes) swap(it->a, it->b);

    sort(cubes.begin(),cubes.begin()+SIZE(big));
    reverse(cubes.begin(),cubes.begin()+SIZE(big));
    sort(cubes.begin()+SIZE(big),cubes.end());
    reverse(cubes.begin()+SIZE(big),cubes.end());
    int res = can_pack_2d_first_fit(skyline, bottom_skyline, cubes, A, B1+B2, 0, 0, 0, 1, last_packing);
    if (res) {
      add_boxes_under(under, last_packing, killed, empty);
    }
    return res;
  }

  if (!can_pack_first_fit_wrapper(skyline, bottom_skyline, big, A, B1, h1, 1, last_packing, 0)) return 0;
  vector<Box> packing = last_packing;

  VI nbig = big;
  VI nsmall = small;

  REP(i,SIZE(v)) if (used.count(v[i].ST.ND) == 0){
    nbig.PB(v[i].ST.ND);
    if (((start >= BORDER_SMALL && v[i].ST.ST > 1.01) || (start < BORDER_SMALL && SIZE(nbig) > topboxes)) || presents[v[i].ST.ND][2] <= h2 || !can_pack_first_fit_wrapper(skyline, bottom_skyline, nbig, A, B1, h1, 1, last_packing, 0)) {
      nsmall.PB(nbig.back());
      nbig.pop_back();
    } else packing = last_packing;
  }
  Skyline s = skyline;
  FOREACH(it, packing) {
    s.update(it->x,it->x+it->a-1, it->y+it->b);
  }
  int border[3] = {0, 0, 999};
  int dir[3] = {1, 1, -1};
  if (!packing.empty()) {
    border[0] = packing.back().border;
    dir[0] = packing.back().dir;
  }

  REP(foo, 3) { 
    int res = can_pack_first_fit_wrapper(s, bottom_skyline, nsmall, A, B1+B2, h2, 1, last_packing, 0, border[foo], dir[foo]); 
    if (res) {
      FOREACH(it, last_packing) packing.PB(*it);
      last_packing = packing;
      add_boxes_under(under, last_packing, killed, empty);
      return 1;
    }
  }

  REP(foo, RANDOM_ROTATIONS) if (start < BORDER_SMALL){
    int res = can_pack_first_fit_wrapper(s, bottom_skyline, nsmall, A, B1+B2, h2, 0, last_packing, foo+1, border[foo%3], dir[foo%3]); 
    if (res) {
      FOREACH(it, last_packing) packing.PB(*it);
      last_packing = packing;
      add_boxes_under(under, last_packing, killed, empty);
      return 1;
    }
  }
  return 0;
}

void extend_packing(int pos, int min_z_offset, int h2, vector<Box> &last_packing, vector<Box> &lower) {
  while (pos < n) {
    Box b = extend_one_box_wrapper(1000, 1000, pos, h2, min_z_offset, lower);
    if (b.a > 0) {
      assert(b.z >= min_z_offset);
      last_packing.PB(b);
      lower.PB(b);
      min_z_offset = b.z;
      pos++;
    } else break;
  }
}


//h1 >= h2
//hint - how many boxes can be packed for sure
int pack_two_regions(const Skyline &skyline, const Skyline &bottom_skyline, int pos, int h1, int h2, int A, int B1, int B2, int topboxes, int longsnake, int hint, vector<Box> &last_packing, const vector<Box> &prev_packing) {
  h1 = max(h1, h2);
  last_packing.clear();
  int r = find_upper_bound(pos, h1, A*(B1+B2));
  int l = pos + hint - 1;
  vector<Box> packing;

  while (l+1 < r) {
    int m = (hint == 0 ? ((l+r) / 2) : l+1);
    if (hint > 0 && presents[m][2] * presents[m][1] * presents[m][0] <= 20 * 20 * 20) {
      l = m;
    } else {
      if (can_pack_two_regions(skyline, bottom_skyline, pos, m, A, B1, B2, h1, h2, topboxes, longsnake, last_packing)){
        l = m;
        packing = last_packing;
        assert(SIZE(last_packing) == m-pos+1);
      } else r = m;
    }
  }
  last_packing = packing;
  if (SIZE(last_packing) > 0) {
    //add more boxes in 3d
    vector<Box> lower = last_packing;
    int min_z_offset = 0;
    FOREACH(it, last_packing) min_z_offset = max(min_z_offset, it->z);
    lower.reserve(SIZE(lower) + SIZE(prev_packing));
    FOREACH(it, prev_packing) if (it->z + it->c > 0) lower.PB(*it);
    extend_packing(pos+SIZE(last_packing), min_z_offset, h2, last_packing, lower);
  }
  return l;
}

LL volume(int a,int b){
  LL res = 0;
  FOR(i,a,b) res += presents[i][0] * presents[i][1] * presents[i][2];
  return res;
}

inline double sqr(double x) {return x * x;}

struct History{
  VI settings; //settings used in the last call of pack_two_regions
  Skyline bottom_skyline; 
  vector<Box> last_packing;
  double sum_ratio; //sum of ratios weighted by volumes
  double last_ratio;

  LL sum_volume; //volume of used boxes
  LL last_volume;
  LL hash;

  int pos;
  int h_island;
  int res; //sum of heights so far, equal to the height of current layer
  int prev_h_island; //used only for asserts to check whether two subsequent layers cross

  int log_number;

  History() : bottom_skyline(1000) {
    bottom_skyline.update(0,999,400);
    last_packing.PB(Box(0,600,0,1000,400,125,0,0,0)); 
    sum_ratio = 0;
    sum_volume = 0;
    pos = 0; 
    res = 0;
    h_island = 125;
    prev_h_island = 125;

    last_ratio = 0.0;
    last_volume = 0;

    log_number = -1; //from which log it was created
  }
};

struct Log {
  VVI settings;
  History history;
};

//updates by using last_packing
void update_history(History &new_hist, int totarea, const vector<Box> &last_packing) {
  int hh = 0;
  FOREACH(it, last_packing){
    hh = max(hh, it->z+it->c);
  }

  //UPDATE SKYLINE
  Skyline new_bottom_skyline(1000);
  FOREACH(it, last_packing) {
    if (it->c + it->z > new_hist.h_island) new_bottom_skyline.update(it->x,it->x+it->a-1,it->y+it->b);
  }

  int ar;
  int t = new_bottom_skyline.find_top_with_area(0,999,ar);
  double tot_vol = totarea * new_hist.h_island + (hh-new_hist.h_island) * (t * 1000 - ar);
  LL new_vol = volume(new_hist.pos,new_hist.pos+SIZE(last_packing)-1);
  double ratio = new_vol / tot_vol;

  new_hist.last_packing = last_packing;

  new_hist.last_ratio = ratio;
  new_hist.last_volume = new_vol;
  new_hist.bottom_skyline = new_bottom_skyline;
  new_hist.sum_ratio += ratio * new_vol;
  new_hist.sum_volume += new_vol;

  new_hist.pos += SIZE(last_packing);
  new_hist.prev_h_island = new_hist.h_island;
  new_hist.h_island = max(0,hh - new_hist.h_island);

  if (new_hist.pos-SIZE(last_packing) < BORDER_SMALL) {
    if (new_hist.pos >= BORDER_SMALL) {
      new_hist.res += max(hh, new_hist.prev_h_island);
      new_hist.h_island = 35;
      new_hist.bottom_skyline = Skyline(1000);
      new_hist.bottom_skyline.update(0,999,400);
    } else {
      new_hist.res += new_hist.prev_h_island;
    }
  } else {
    new_hist.res += new_hist.prev_h_island;
  }
  if (new_hist.pos == n) {
    new_hist.res += new_hist.h_island;
  }

  const int P = 1000000007;
  LL hash = 0;
  hash = hash * P + (new_hist.h_island+123);
  hash = hash * P + new_hist.pos;
  new_hist.hash = hash;
}

void add_packing_to_output(VVI &output, int res, const vector<Box> &last_packing) {
  REP(i,SIZE(last_packing)) {
    Box b = last_packing[i];
    VI v;
    v.PB(b.id);

    int offset[] = {b.x,b.y,b.z+res+b.c-1};
    int dim[] = {b.a, b.b, -b.c+2};
    REP(mask,8) {
      REP(i,3) {
        v.PB(offset[i] + ((mask & (1<<i))? dim[i]-1 : 0));
      }
    }
    output.PB(v);
  }
}

#ifdef VISUALIZE
void visualize(History actual, vector<Box> best_packing, int h_island) {
  static int num_layer = 0;
  CImg<unsigned char> vis(1000,1000,1,3,0);
  unsigned char yellow[] = {255,255,0};
  unsigned char blue[] = {0, 0, 255};
  int h = 0;
  FOREACH(it, best_packing) h = max(h, it->z + it->c);

  FOREACH(it, actual.bottom_skyline.s) {
    vis.draw_rectangle(it->ST.ST, 999-it->ND, it->ST.ND, 999, yellow);
  }

  FOREACH(it, best_packing) {
    unsigned char col[] = {0,0,0};
    int z = it->c;
    assert(0 <= z && z <= 250);
    if (z > h_island) {
      col[0] = z;
    } else {
      col[1] = 75 + z;
    }
    if (it->dir == -4) {
      col[2] = 125;
    }
    if (it->dir == -3) {
      col[2] = 255;
    }
    if (it->dir == -2) {
      col[0] = 125;
      col[1] = 125;
      col[2] = 125;
    }
    vis.draw_rectangle(it->x,it->y,it->x+it->a-1,it->y+it->b-1,col);
  }

  char txt[30];
  sprintf(txt, "layer%da.bmp", num_layer);
  vis.save(txt);
  num_layer++;
}
#endif

void expand(History actual, vector<History> &new_pool, vector<History> &pool_computed, VI settings, int add_to_output, VVI &output, int layer, int settings_log_number) {
  Skyline skyline(1000);
  vector<Box> last_packing;
  assert(actual.pos < n);
  actual.h_island = max(actual.h_island, 0);

  int totarea;
  int W = 1000;
  int t = actual.bottom_skyline.find_top_with_area(0,999,totarea);
  totarea = (1000-t) * 1000 + totarea;

  REP(reflect, REFLECTIONS) { 
    FOR(longsnake,0,1) {
      set<int> heights;
      FORD(h,250,220) if (add_to_output || h==250 || heights.count(h)) {
        if (actual.pos >= BORDER_SMALL) h = 70; 
        int hint = 0;
        int how_many_packed = 0;
        FOR(topboxes,1,30) {
          FOR(w1,500,500) {
            VI new_settings;
            new_settings.PB(h); new_settings.PB(topboxes); new_settings.PB(longsnake); new_settings.PB(w1); new_settings.PB(reflect);
            new_settings.PB(hint);
            if (!settings.empty()) {
              int fit = 1;
              REP(a,5) if (new_settings[a] != settings[a]) {
                fit = 0;
                break;
              }
              if (!fit) continue;
              hint = settings[5];
            }

            int w2 = W-w1;
            pack_two_regions(skyline, actual.bottom_skyline, actual.pos, h, actual.h_island, 1000, w1, w2, topboxes, longsnake, hint, last_packing, actual.last_packing);
            if (SIZE(last_packing) == 0) continue;

            if (reflect) {
              FOREACH(it, last_packing) {
                it->x = 999-(it->x+it->a-1);
              }
            }

            hint = max(hint, SIZE(last_packing));
            how_many_packed = max(how_many_packed, SIZE(last_packing));
            if (add_to_output) {
#ifdef VISUALIZE
              if (reflect) {
                FOREACH(it, last_packing) {
                  it->x = 999-(it->x+it->a-1);
                }
              }
              visualize(actual, last_packing, actual.h_island);
              if (reflect) {
                FOREACH(it, last_packing) {
                  it->x = 999-(it->x+it->a-1);
                }
              }
#endif
              if (layer % 2) {
                FOREACH(it, last_packing) {
                  it->y = 999-(it->y+it->b-1);
                }
              }
              int i = actual.pos + SIZE(last_packing);
              add_packing_to_output(output, actual.res, last_packing);
              if (layer % 2) {
                FOREACH(it, last_packing) {
                  it->y = 999-(it->y+it->b-1);
                }
              }
            }

            History new_hist(actual);
            new_hist.log_number = settings_log_number;
            new_hist.settings = new_settings; 
            update_history(new_hist, totarea, last_packing);
            FOREACH(it, new_hist.last_packing) {
              it->y = 999-(it->y+it->b-1);
              it->z -= actual.h_island;
            }
            if (add_to_output){
              int pole = 0;
              FOREACH(it, last_packing) pole += it->a * it->b;
            }
            if (new_hist.pos == n) pool_computed.PB(new_hist);
            else new_pool.PB(new_hist);
          }
          if (h == 70) break;
        }
        FOR(i,actual.pos,actual.pos+how_many_packed-1) REP(j,3) heights.insert(presents[i][j]);
      }
    }
    FOREACH(it,actual.bottom_skyline.s) {
      swap(it->ST.ST,it->ST.ND);
      it->ST.ST = 999-it->ST.ST;
      it->ST.ND = 999-it->ST.ND;
    }
    FOREACH(it,actual.last_packing) {
      it->x = 999-(it->x+it->a-1);
    }
  }
}


// choose one of the logs and compute output
VVI compute_output(const Log &log) {

  vector<VI> output;
  History actual;
  int layer = 0;
  FOREACH(it, log.settings) {
    vector<History> new_pool, new_pool_computed;
    expand(actual, new_pool, new_pool_computed, *it, 1, output, layer, -1); //settings_log_number_not_important
    assert(SIZE(new_pool_computed) + SIZE(new_pool) == 1); 
    if (!new_pool.empty()) {
      actual = new_pool[0];
    } else {
      actual = new_pool_computed[0];
    }
    layer++;
  }
  //HACK - used only for runs with small values of n
  if (actual.pos < BORDER_SMALL) {
    actual.res += 250;
  }

  REP(i, SIZE(output)) {
    int j = 3;
    while (j < SIZE(output[i])){
      output[i][j] = actual.res-1 - output[i][j];
      j+=3;
    }
  }
  return output;
}

void print_output(VVI &output) {
  puts("PresentId,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8");
  sort(ALL(output));
  REP(i,SIZE(output)) {
    int j = 0;
    while (j < SIZE(output[i])) {
      if (j) printf(",");
      printf("%d", output[i][j]+1);
      j++;
    }
    puts("");
  }
}

double how_close_to_pool(const History &h, const vector<Log> &pool) {
  double res = (h.sum_ratio-h.last_ratio * h.last_volume + h.last_ratio * h.last_volume * pow(0.93,sqr(h.h_island-125)/2500)) / h.sum_volume;
  FOREACH(it, pool) {
    if (h.hash == it->history.hash) return -1.0;
  }
  return res;
}

vector<Log> pool;
vector<History> new_pool[NUM_THREADS];
vector<History> pool_computed[NUM_THREADS];

void thread_expand2(int r, int layer) {
  VVI output; //mock
  int pos = r;
  int x = pool.size();
  while (pos < x) {
    expand(pool[pos].history, new_pool[r], pool_computed[r], VI(), 0, output, layer, pos);
    pos += NUM_THREADS;
  }
}

Log find_best_log() {
  Log res;
  int best_res = 1001 * 1001 * 1001;
  int layer = 0;
  pool.PB(Log());

  vector<Log> new_logs;
  vector<History> new_pool_gathered, pool_computed_gathered;
  std::thread threads[NUM_THREADS];
  while (!pool.empty()) {
    REP(i,NUM_THREADS) {
      threads[i] = std::thread(thread_expand2, i, layer);
    }
    REP(i,NUM_THREADS) {
      threads[i].join();
    }
    REP(i,NUM_THREADS) FOREACH(it, new_pool[i]) new_pool_gathered.PB(*it);
    REP(i,NUM_THREADS) FOREACH(it, pool_computed[i]) pool_computed_gathered.PB(*it);
    REP(i,NUM_THREADS) {
      new_pool[i].clear();
      pool_computed[i].clear();
    }

    //searching pool computed
    while (!pool_computed_gathered.empty()) {
      if (pool_computed_gathered.back().res < best_res) {
        best_res = pool_computed_gathered.back().res;
        res.history = pool_computed_gathered.back();
        res.settings = pool[res.history.log_number].settings;
        res.settings.PB(res.history.settings);
      }
      pool_computed_gathered.pop_back();
    }

    while (SIZE(new_logs) < POOL_SIZE && SIZE(new_pool_gathered) > 0) {
      double best_score = -1.0;
      int which = 0;
      REP(i, SIZE(new_pool_gathered)) {
        double cand_score = how_close_to_pool(new_pool_gathered[i], new_logs);
        if (cand_score > best_score) {
          best_score = cand_score;
          which = i;
        }
      }
      if (SIZE(new_logs) == 0) {
        fprintf(stderr, "newacumratio = %.6lf newpos = %d newhisland = %d newres = %d\n", new_pool_gathered[which].sum_ratio/new_pool_gathered[which].sum_volume, new_pool_gathered[which].pos, new_pool_gathered[which].h_island, new_pool_gathered[which].res);
        fflush(stderr);
      }
      if (best_score < -0.5) break;
      swap(new_pool_gathered[which], new_pool_gathered.back());
      Log new_log;
      new_log.history = new_pool_gathered.back();
      new_log.settings = pool[new_pool_gathered.back().log_number].settings;
      new_log.settings.PB(new_pool_gathered.back().settings);
      new_logs.PB(new_log);
      new_pool_gathered.pop_back();
      if (new_log.history.pos >= BORDER_SMALL) break; //when we go to small presents there is no need for beam search
    }
    new_pool_gathered.clear();
    pool.clear();
    swap(pool, new_logs);

    layer++;
  }
  assert(res.history.res > 0);
  return res;
}

int main(){
  srand(123);
  REP(i,R) random_numbers[i] = rand();
  REP(i,n) {
    int id,a,b,c;
    scanf("%d %d %d %d",&id,&a,&b,&c);
    id--;
    presents[id][0] = a;
    presents[id][1] = b;
    presents[id][2] = c;
    sort(presents[id],presents[id]+3);
  }
  Log log = find_best_log();

  vector<VI> output = compute_output(log);

  print_output(output);
  return 0;
}
