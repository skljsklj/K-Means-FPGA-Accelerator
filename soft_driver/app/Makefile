CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++11 -I/usr/local/include/opencv4 -I/usr/local/system-2.3.3/include
LDFLAGS = -L/usr/local/system-2.3.3/lib-linux64 -Wl,-rpath=/usr/local/systemc-2.3.3/lib-linux64
LDLIBS = -lsystemc -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs
SRCS = user_app.cpp
OBJS = $(SRCS:.cpp=.o)

TARGET = user_app

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET) ../../data/*SPEC.jpg

