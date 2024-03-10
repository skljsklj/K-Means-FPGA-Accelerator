CC = g++
CFLAGS = -I/usr/include/opencv4
LIBS = -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs
TARGET = spec/main
SRC = spec/main.cpp

CXX = g++
CXXFLAGS = -I/usr/local/include/opencv4 -I/usr/local/system-2.3.3/include
LDFLAGS = -L/usr/local/system-2.3.3/lib-linux64 -Wl,-rpath=/usr/local/systemc-2.3.3/lib-linux64
LDLIBS = -lsystemc -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs

# Source files for your bit_analysis
BIT_SRC = $(wildcard spec/bit_analysis/*.cpp)

# Object files for bit_analysis
BIT_OBJECTS = $(patsubst %.cpp, %.o, $(BIT_SRC))

# Executable for bit_analysis
BIT_EXECUTABLE = spec/bit_analysis/primer

VP_SRC = $(wildcard vp/*.cpp)
VP_OBJECTS = $(patsubst %.cpp, %.o, $(VP_SRC))
VP_EXECUTABLE = vp/vp_executable

.PHONY: all clean spec bit_analysis run_spec run_bit_analysis vp run_vp

all: spec bit_analysis vp

spec: $(TARGET) 

bit_analysis: $(BIT_EXECUTABLE)

vp: $(VP_EXECUTABLE)

$(TARGET): $(SRC)
	$(CC) -o $(TARGET) $(SRC) $(CFLAGS) $(LIBS)

$(BIT_EXECUTABLE): $(BIT_OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(VP_EXECUTABLE): $(VP_OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

run_spec: $(TARGET)
	./$(TARGET) $(ARGS)

run_bit_analysis: $(BIT_EXECUTABLE)
	./$(BIT_EXECUTABLE) $(ARGS)

run_vp: $(VP_EXECUTABLE)
	./$(VP_EXECUTABLE) $(ARGS)

run: run_spec run_bit_analysis run_vp

clean:
	rm -f $(TARGET) $(BIT_EXECUTABLE) $(VP_EXECUTABLE) $(BIT_OBJECTS) $(VP_OBJECTS) data/*.jpg

