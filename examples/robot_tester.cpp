#include "robot_tester.h"

#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <unistd.h>

RobotTester::RobotTester(int map_size, env_map* p_em) {
  size = map_size;
  p_env_action = p_em;
  map = new int*[size];
  x = 0; y = 0;
  for (int i = 0; i < size; i++) {
    map[i] = new int[size];
  }
}

RobotTester::~RobotTester() {
  for (int i = 0; i < size; i++) {
    delete map[i];
  }
}

int RobotTester::test(int step, analyse_callback cb, bool play = false) {
  int score = 0;
  char env[6] = {0, 0, 0, 0, 0, 0};
  int action;
  env_map::iterator em_itor;
  x = 0; y = 0;

  rand_map();

  for (int i = 0; i < step; i++) {
    scan_env(env);
    em_itor = p_env_action->find(env);
    if (em_itor != p_env_action->end()) {
      action = em_itor->second;
    } else {
      action = cb(env);
      p_env_action->insert(env_map::value_type(env, action));
    }

    score = score + execute_action(action == 0 ? (rand() % 4 + 1) : action);
    if (play) {
      show_map();
      usleep(100 * 1000);
    }
  }

  return score;
}

void RobotTester::rand_map() {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      map[i][j] = rand() % 2;
    }
  }
}

const int scan_len = 5;
const int scan_points[scan_len][2] = {
  {0, -1},
  {-1, 0}, {0, 0}, {1, 0},
  {0, 1}
};
void RobotTester::scan_env(char* env) {
  int sx, sy;
  for (int i = 0; i < scan_len; i++) {
    sx = x + scan_points[i][0];
    sy = y + scan_points[i][1];

    if (sx < 0 || sx >= size || sy < 0 || sy >= size) {
      env[i] = '2';
      continue;
    }
    env[i] = char(map[sx][sy] + 48);
  }
}

void RobotTester::show_map() {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      printf(" %i%c", map[j][i], (x == j and y == i) ? '*' : ' ');
    }
    printf("\n");
  }
  printf("\n");
}

// 1 2 3 4 move
// 5 take
//   1
// 2 5 3
//   4  
const int actions[5][2] = {
  {0, 0}, {0, -1}, {-1, 0}, {1, 0}, {0, 1}
};
int RobotTester::execute_action(int action) {
  switch(action) {
  case 5: {
    if (map[x][y] == 1) {
      map[x][y] = 0;
      return 10;
    } else {
      return -1;
    }
  }
  case 1:
  case 2:
  case 3:
  case 4: {
    int mx = x + actions[action][0];
    int my = y + actions[action][1];
    if (mx < 0 || mx >= size || my < 0 || my >= size) {
      return -5;
    } else {
      x = mx; y = my;
      return 0;
    }
  }
  default:
    printf("Invalid action %i\n", action);
    throw("Invalid action\n");
  }
}

typedef std::unordered_map<std::string, short> env_map;


extern "C" {
  int robot_test(int times, int step, char** envs, short* actions, int elen, analyse_callback cb) {
    srand(time(0));

    env_map emap;
    for (int i = 0; i < elen; i++) {
      emap.insert(env_map::value_type(envs[i], actions[i]));
    }

    RobotTester rt = RobotTester(10, &emap);
    int total_score = 0;
    
    for (int i = 0; i < times; i++) {
      total_score = total_score + rt.test(step, cb, times == 1);
    }

    return total_score / times;
  }
}

