/*
 *  raw_drawing.h
 *  Image Recognition
 *
 *  Created by Jean-Louis on 2010-02-01.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef RAW_DRAWING_H
#define RAW_DRAWING_H
void lineBresenham(int x0, int y0, int x1, int y1, unsigned char* data, int bitmapBytesPerRow);
#endif