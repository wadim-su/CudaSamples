#include "DeviceCalculations.cuh"

#include <thrust/device_vector.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/transform.h>
#include <thrust/reduce.h>

#include <curand.h>


struct inside_circle
{
  __device__ int8_t operator()(const thrust::tuple<float, float>& p) const
  {
    return (((thrust::get<0>(p) - 0.5) * (thrust::get<0>(p) - 0.5) + (thrust::get<1>(p) - 0.5) * (thrust::get<1>(p) - 0.5)) < 0.25) ? 1 : 0;
  }
};

__host__
size_t calc_on_device(size_t numberOfPoints)
{
  thrust::device_vector<float> pointsX(numberOfPoints);
  thrust::device_vector<float> pointsY(numberOfPoints);

  // Generate random points using cuRAND
  curandGenerator_t generator;
  curandCreateGenerator(&generator, /*CURAND_RNG_QUASI_DEFAULT*/CURAND_RNG_PSEUDO_DEFAULT);

  curandGenerateUniform(generator, thrust::raw_pointer_cast(pointsX.data()), numberOfPoints);
  curandGenerateUniform(generator, thrust::raw_pointer_cast(pointsY.data()), numberOfPoints);

  // Count points inside circle using reduction from Thrust
  thrust::device_vector<int8_t> insideCircle(numberOfPoints);

  auto first = thrust::make_zip_iterator(thrust::make_tuple(pointsX.begin(), pointsY.begin()));
  auto last  = thrust::make_zip_iterator(thrust::make_tuple(pointsX.end()  , pointsY.end()  ));

  thrust::transform(first, last, insideCircle.begin(), inside_circle());
  size_t total = thrust::reduce(insideCircle.begin(), insideCircle.end(), (size_t)0, thrust::plus<size_t>());

  return total;
}
