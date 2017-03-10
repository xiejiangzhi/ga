#include "robot_tester.h"

#include <cstdio>
#include <cstdlib>

#include <unordered_map>
#include <string>

int analyse_env(const char* const env) {
  return rand() % 6;
}

typedef std::unordered_map<std::string, short> env_hash;

int main() {
  env_hash eh;
  int step = 200;
  int times = 200;

  printf("'robot_test' avg score: %i\n", robot_test(times, step, NULL, NULL, 0, analyse_env));

  RobotTester rt = RobotTester(10, &eh);
  int total_score = 0;
  printf("env_hash size: %i\n", (int)eh.size());
    
  for (int i = 0; i < times; i++) {
    total_score = total_score + rt.test(step, analyse_env, false);
  }

  printf("env_hash size: %i\n", (int)eh.size());
  printf("'RobotTester#test' avg score: %i\n", total_score / times);

  return 0;
}

