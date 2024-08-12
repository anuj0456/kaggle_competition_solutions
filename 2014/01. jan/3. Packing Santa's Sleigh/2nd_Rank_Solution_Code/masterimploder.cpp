#include <vector>
#include <iostream>
#include <sstream>
#include <math.h>
#include <sys/time.h>
#include <cstdlib>
#include <algorithm>
#include <cassert>
#include <cstring>
#include <fstream>
#include <set>

#define FOR(i,a,b)  for(__typeof(b) i=(a);i<(b);++i)
#define REP(i,a)    FOR(i,0,a)
#define FOREACH(x,c)   for(__typeof(c.begin()) x=c.begin();x != c.end(); x++)
#define ALL(c)      c.begin(),c.end()
#define CLEAR(c)    memset(c,0,sizeof(c))
#define SIZE(c) (int) ((c).size())

#define PB          push_back
#define MP          make_pair
#define X           first
#define Y           second

#define ULL         unsigned long long
#define LL          long long
#define LD          long double
#define II         pair<int, int>
#define DD         pair<double, double>

#define VI          vector<int>
#define VVI         vector<VI >
#define VD                      vector<double>
#define VS          vector<string >
#define VII        vector<II >
#define VDD         vector< DD >

#define DUMP(a)       cerr << #a << ": " << a << endl;
using namespace std;

#define N 1000000
#define W 1000
#define HEADER string("PresentId,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8")

class Present{
public:
	int id;
	int xmin[3];
	int xmax[3];
	friend istream &operator>>(istream &i, Present &p);
	friend ostream &operator<<(ostream &o, Present &p);
};

istream &operator>>(istream &is, Present &p){
	char c;
	int x[3];
	is >> p.id;
	REP(i,8) {
		REP(j,3)
			is >> c >> x[j];
		if (i == 0){
			REP(j,3)
				p.xmin[j] = p.xmax[j] = x[j];
		} else{
			REP(j,3){
				if (x[j] > p.xmax[j])
					p.xmax[j] = x[j];
				else if (x[j] < p.xmin[j])
					p.xmin[j] = x[j];
			}		
		}
	}
	return is;
}

ostream &operator<<(ostream &o, Present &p){
	o << p.id;
	int i[3];
	for(i[0]=0;i[0]<2;i[0]++) 
	for(i[1]=0;i[1]<2;i[1]++) 
	for(i[2]=0;i[2]<2;i[2]++){ 
		REP(j,3)
			o << "," << (i[j]?p.xmax[j]:p.xmin[j]);		
	}
	o << "\n";
	return o;
}

struct Present_Zrev{
	bool operator()(Present const &p, Present const &q) const{
		if (p.xmax[2] != q.xmax[2])
			return (p.xmax[2] > q.xmax[2]);
		else
			return (p.id < q.id);	
	}
} Present_Zrev_CMP;

struct Present_ID{
	bool operator()(Present const &p, Present const &q) const{
		return p.id < q.id;	
	}
} Present_ID_CMP;

vector<Present> p(N);

void read_data(){
	ifstream f("answer.csv");
	string header;
	f >> header;
	REP(i,N)
		f >> p[i];
	f.close();
};

void write_data(){
	ofstream f("optimized.csv");
	f << HEADER << endl;
	REP(i,N)
		f << p[i];
	f.close();
}

void inside_test(){
	REP(i,N)
		if (p[i].xmin[0] < 1 || p[i].xmax[0] > W || p[i].xmin[1] < 1 || p[i].xmax[1] > W || p[i].xmin[2] < 1){
			cout << "PRESENT " << p[i].id << " OUT OF BOUNDS" << endl;
			return;
		}
	cout << "ALL PRESENTS IN BOUNDS" << endl;			
}

inline bool interval_intersect_test(int x1, int x2, int y1, int y2){
	return  !(x2 < y1 || y2 < x1);
}

inline bool item_intersect_test(int i, int j){
	if (!interval_intersect_test(p[i].xmin[0],p[i].xmax[0],p[j].xmin[0],p[j].xmax[0]))
		return false;
	if (!interval_intersect_test(p[i].xmin[1],p[i].xmax[1],p[j].xmin[1],p[j].xmax[1]))
		return false;
	return true;
}

void intersect_test(){
	sort(ALL(p),Present_Zrev_CMP);
	vector<II> events;
	events.reserve(2*N);
	REP(i,N){
		events.PB(MP(2*p[i].xmin[2],i));
		events.PB(MP(2*p[i].xmax[2]+1,i)); // first begins then ends
	}
	sort(ALL(events));

	set<int> sweep;
	vector<bool> insweep(N,false);

	FOREACH(e,events)
		if (insweep[e->Y]){
			sweep.erase(e->Y);
			insweep[e->Y] = false;
		}else{
			FOREACH(x,sweep){
				if (item_intersect_test(*x,e->Y)){	
					cout << "ITEMS " << *x << " AND " << e->Y << " INTERSECT" << endl;
					return;
				}
			}
			sweep.insert(e->Y);
			insweep[e->Y] = true;
		}
	cout << "NO INTERSECTIONS DETECTED" << endl;
}

void optimize(){
	cout << "OPTIMIZING" << endl;
	sort(ALL(p),Present_ID_CMP);
	reverse(ALL(p));
	vector<II> events;
	events.reserve(2*N);
	REP(i,N){
		events.PB(MP(p[i].xmax[2],i));
		events.PB(MP(p[i].xmax[2]+400,i));	// TODO: THIS IS SILLY AND JUST WRONG
	}
	sort(ALL(events));

	set<int> sweep;
	vector<bool> in_sweep(N,false);
	int level = 0;

	FOREACH(e,events){
		if (in_sweep[e->Y]){
			in_sweep[e->Y] = false;
			sweep.erase(e->Y);
			continue;
		}
		int ground = 0;
		FOREACH(x,sweep)
			if (item_intersect_test(*x,e->Y))
				ground = max(ground,p[*x].xmax[2]);
		
		//cout << "(" << p[e->Y].xmax[2]-level << " " << p[e->Y].xmin[2]-ground-1 << ")";
		int shift = min(p[e->Y].xmax[2]-level, p[e->Y].xmin[2]-ground-1);
		if (shift > 0){
			p[e->Y].xmax[2] -= shift;
			p[e->Y].xmin[2] -= shift;			
		}
		sweep.insert(e->Y);
		in_sweep[e->Y] = true;
		level = max(level,p[e->Y].xmax[2]);
	}
}

void score(){
	sort(ALL(p),Present_Zrev_CMP);
	int h_score = 2*p[0].xmax[2];
	int o_score = 0;
	REP(i,N)
		o_score += abs(i+1-p[i].id);
	cout << "H_SCORE: " << h_score << " O_SCORE: " << o_score << " TOTAL: " << h_score + o_score << endl;
}

int main(int argc, char *argv[]){
	ios_base::sync_with_stdio(false);
	read_data();
	inside_test();
	intersect_test();
	score();
	optimize();
	intersect_test();
	score();
	write_data();
}
