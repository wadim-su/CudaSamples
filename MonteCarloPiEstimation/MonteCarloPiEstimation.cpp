// MonteCarloPiEstimation.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <vector>

#include "DeviceCalculations.cuh"

int main()
{
  size_t numberOfPoints = 5000000;
  size_t pointsInsideCircle = calc_on_device(numberOfPoints);

  std::cout << "PI: " << 4.0f * pointsInsideCircle / (float)numberOfPoints << '\n';

  return 0;
}
