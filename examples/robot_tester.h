#ifndef  ROBOT_TESTER_H
#define ROBOT_TESTER_H

#include <unordered_map>
#include <string>

typedef int(*analyse_callback)(const char* const);
typedef std::unordered_map<std::string, short> env_map;

class RobotTester {
public:
  RobotTester(int, env_map*);
  ~RobotTester();
  int test(int, analyse_callback, bool play);

  void rand_map();
  void show_map();

private:
  env_map* p_env_action;
  int size;
  int **map;
  int x;
  int y;

  void scan_env(char[5]);
  int execute_action(int);
};


extern "C" {
  int robot_test(int times, int step, char** envs, short* action, int elen, analyse_callback);
}

#endif

