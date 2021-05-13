/*
 ____  _____ _        _
| __ )| ____| |      / \
|  _ \|  _| | |     / _ \
| |_) | |___| |___ / ___ \
|____/|_____|_____/_/   \_\
http://bela.io
*/

#include <libraries/Trill/Trill.h>
#include <vector>
#include <chrono>
#include <MiscUtilities.h>

using namespace std::chrono;

#define LOG_RAW
#ifdef LOG_RAW
const size_t kMaxNumPads = 30;
#include <libraries/Trill/CentroidDetection.h>
#else // LOG_RAW
const size_t kMaxNumPads = 0;
#endif // LOG_RAW
struct Frame { double timestamp; float position; float size; float pads[kMaxNumPads]; };

float gNumFrames = 5000;

int main()
{
	// pre-allocate all the memory needed to store the audio data
	struct Frame oldFrame = {0};
	unsigned int bits = 10;
	unsigned int pres = 2;
#ifdef LOG_RAW
	unsigned int multBits = 11;
#endif // LOG_RAW
	std::vector<struct Frame> inputs(gNumFrames);
	Trill trill;
	trill.setup(1, Trill::RING);
	usleep(10000);
	trill.setScanSettings(0, bits);
	usleep(10000);
	trill.setPrescaler(pres);
	usleep(10000);
	trill.updateBaseline();
#ifdef LOG_RAW
	trill.setMode(Trill::DIFF);
	CentroidDetection cent(28, 5, 1); // Ring has 28 pads
	cent.setWrapAround(5); // consider up to 5 pads when wrapping around
	cent.setMultiplierBits(multBits);
#endif // LOG_RAW
	auto start = std::chrono::steady_clock::now();
	for(unsigned int n = 0; n < inputs.size(); ++n)
	{
		struct Frame frame;
		while(1)
		{
			// read as fast as possible but only keep the frame if different from the previous one
			// (empirical workaround to only take new readings)
			if(trill.readI2C())
			{
				return 1;
			}
#ifdef LOG_RAW
			cent.process(trill.rawData.data());
			auto& touches = cent;
#else
			auto& touches = trill;
#endif // LOG_RAW
			if(!touches.getNumTouches()) {
				frame.position = -1;
				frame.size = 0;
			} else {
				frame.position = touches.touchLocation(0);
				frame.size = touches.touchSize(0);
			}
			if(frame.position != oldFrame.position || frame.size != oldFrame.size)
			{
				if((n % 100) == 0)
					printf("n %d\n", n);
				auto end = std::chrono::steady_clock::now();
				std::chrono::duration<double> elapsed_seconds = end - start;
				frame.timestamp = elapsed_seconds.count();
				oldFrame.position = frame.position;
				oldFrame.size = frame.size;
				break;
			}
			usleep(100);
		}
		inputs[n].position = frame.position;
		inputs[n].size = frame.size;
		inputs[n].timestamp = frame.timestamp;
#ifdef LOG_RAW
		for(unsigned int i = 0; i < kMaxNumPads && i < trill.rawData.size(); ++i)
		{
			inputs[n].pads[i] = trill.rawData[i];
		}
#endif // LOG_RAW
	}
	std::string type;
#ifdef LOG_RAW
	type = "_raw_mult" + std::to_string(multBits);
#endif // LOG_RAW
	std::string filename = "ring" + type + "_bits" + std::to_string(bits) + "_pres" + std::to_string(pres) + ".m";
	printf("Stopped, writing '%s'\n", filename.c_str());
	std::string out = "data =[\n";
	for(auto& f : inputs)
	{
		out += std::to_string(f.timestamp) + "," + std::to_string(f.position) + "," + std::to_string(f.size) + ",";
#ifdef LOG_RAW
		for(unsigned int n = 0; n < kMaxNumPads; ++n)
			out += std::to_string(f.pads[n]) + ",";
#endif // LOG_RAW
		out += "\n";
	}
	out += "];";
	IoUtils::writeTextFile(filename, out);
	return 0;
}