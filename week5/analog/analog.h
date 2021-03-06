// This file is part of the Firestorm Software Distribution.
//
// FSD is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// FSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with FSD.  If not, see <http://www.gnu.org/licenses/>.

// Author: Michael Andersen <m.andersen@cs.berkeley.edu>

#ifndef __ANALOG_H__
#define __ANALOG_H__

#define ANALOG_REFGND_N 21

typedef struct
{
    uint8_t poschan;
    uint8_t negchan;
    uint8_t gain;
    uint8_t resolution;
} __attribute__((packed)) storm_adc_t;

int adcife_sample(lua_State *L);
int adcife_init(lua_State *L);
int adcife_new(lua_State *L);

void c_adcife_init();
int c_adcife_sample_channel(uint8_t poschan, uint8_t negchan, uint8_t gain, uint8_t resolution);

#endif