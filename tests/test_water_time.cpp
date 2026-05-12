// Tests for the water-time encode/decode quantization used in
// utils.cpp:water_time_encode_signed and water_time_decode_signed.
//
// The function bodies are copied here rather than linked from utils.cpp
// because utils.cpp pulls in OpenSprinkler.h and the whole controller
// dependency graph. The duplication is a known cost of the current
// architecture; a follow-up should extract pure math into a standalone
// translation unit so production and tests share a single source.
//
// If utils.cpp:water_time_*_signed changes, mirror the change here.

#include "doctest.h"
#include <stdint.h>

namespace {

unsigned char encode(int16_t i) {
	i = (i > 600) ? 600 : i;
	i = (i < -600) ? -600 : i;
	return (i + 600) / 5;
}

int16_t decode(unsigned char i) {
	i = (i > 240) ? 240 : i;
	return ((int16_t)i - 120) * 5;
}

} // namespace

TEST_CASE("encode endpoints and midpoint") {
	CHECK(encode(-600) == 0);
	CHECK(encode(0)    == 120);
	CHECK(encode(600)  == 240);
}

TEST_CASE("encode clamps out-of-range inputs") {
	CHECK(encode(-1000) == 0);
	CHECK(encode( 1000) == 240);
	CHECK(encode(INT16_MIN) == 0);
	CHECK(encode(INT16_MAX) == 240);
}

TEST_CASE("decode endpoints and midpoint") {
	CHECK(decode(0)   == -600);
	CHECK(decode(120) == 0);
	CHECK(decode(240) == 600);
}

TEST_CASE("decode clamps the high end") {
	CHECK(decode(250) == 600);
}

TEST_CASE("round-trip is exact on the 5-unit grid") {
	for (int i = -600; i <= 600; i += 5) {
		CHECK(decode(encode((int16_t)i)) == i);
	}
}
