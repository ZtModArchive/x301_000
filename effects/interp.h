
#ifndef FX_INTERP_H
#define FX_INTERP_H

float4 sawtooth(float4 abscissa)
{
	float4 v = frac(abscissa);	// v is modulo'd to [0..1]
	v *= 2.f;					// v is stretched [0..2]
	float4 x = min(v, 1.f);		// clamps [0..2]=>[0..1]
	v = 2.f - v;				// remap [0..2]=>[2..0]
	float4 y = min(v, 1.f);		// clamp [2..0]=>[1..0]
	v = x * y;					// v is [0..1..0]
	
	return v;
}

float4 smoothnoclamp(float4 v)
{
	float4 x = v * v;					// v^2
	float4 y = x * v;					// v^3
	v = 3.f * x;
	v += -2.f * y; // vector v is smoothstepped vin with [0..1..0] cycle over interval one.
	
	return v;
}


float4 smoothwave(float4 abscissa)
{
	return smoothnoclamp(sawtooth(abscissa));
}


#endif // FX_INTERP_H