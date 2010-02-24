/*
 Copyright (c) 2007-2010, Trustees of The Leland Stanford Junior University
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without 
 modification,are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, 
 this list of conditions and the following disclaimer. Redistributions in 
 binary form must reproduce the above copyright notice, this list of 
 conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution. Neither the name of the 
 Stanford University nor the names of its contributors may be used to 
 endorse or promote products derived from this software without
 specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE.
 */

/* Instruction ROM for Pacoblaze microcontroller:
 * ROM holds instructions for UART and ascii conversion 
 * */
module irom(address,instruction,clk,reset);
   input [9:0] address;
   output reg [17:0] instruction;
   input 	     clk;
   input 	     reset;
   reg [17:0] 	     cinstruction;
   
   
   always@(posedge clk)
     begin
	instruction <= reset ? 18'd0 : cinstruction;
     end
   

   always@(*)
     begin
	case(address)
	  10'd0:
	    cinstruction = 18'd245761;
	  10'd1:
	    cinstruction = 18'd1280;
	  10'd2:
	    cinstruction = 18'd1792;
	  10'd3:
	    cinstruction = 18'd323;
	  10'd4:
	    cinstruction = 18'd196771;
	  10'd5:
	    cinstruction = 18'd342;
	  10'd6:
	    cinstruction = 18'd196771;
	  10'd7:
	    cinstruction = 18'd321;
	  10'd8:
	    cinstruction = 18'd196771;
	  10'd9:
	    cinstruction = 18'd269;
	  10'd10:
	    cinstruction = 18'd196771;
	  10'd11:
	    cinstruction = 18'd83200;
	  10'd12:
	    cinstruction = 18'd217091;
	  10'd13:
	    cinstruction = 18'd83713;
	  10'd14:
	    cinstruction = 18'd200872;
	  10'd15:
	    cinstruction = 18'd82258;
	  10'd16:
	    cinstruction = 18'd200730;
	  10'd17:
	    cinstruction = 18'd82290;
	  10'd18:
	    cinstruction = 18'd200730;
	  10'd19:
	    cinstruction = 18'd82263;
	  10'd20:
	    cinstruction = 18'd200823;
	  10'd21:
	    cinstruction = 18'd82295;
	  10'd22:
	    cinstruction = 18'd200823;
	  10'd23:
	    cinstruction = 18'd53248;
	  10'd24:
	    cinstruction = 18'd53248;
	  10'd25:
	    cinstruction = 18'd213005;
	  10'd26:
	    cinstruction = 18'd2563;
	  10'd27:
	    cinstruction = 18'd83713;
	  10'd28:
	    cinstruction = 18'd218139;
	  10'd29:
	    cinstruction = 18'd82208;
	  10'd30:
	    cinstruction = 18'd218139;
	  10'd31:
	    cinstruction = 18'd1792;
	  10'd32:
	    cinstruction = 18'd83713;
	  10'd33:
	    cinstruction = 18'd218144;
	  10'd34:
	    cinstruction = 18'd1792;
	  10'd35:
	    cinstruction = 18'd192928;
	  10'd36:
	    cinstruction = 18'd84480;
	  10'd37:
	    cinstruction = 18'd217128;
	  10'd38:
	    cinstruction = 18'd117249;
	  10'd39:
	    cinstruction = 18'd213024;
	  10'd40:
	    cinstruction = 18'd3072;
	  10'd41:
	    cinstruction = 18'd196703;
	  10'd42:
	    cinstruction = 18'd183056;
	  10'd43:
	    cinstruction = 18'd196703;
	  10'd44:
	    cinstruction = 18'd183057;
	  10'd45:
	    cinstruction = 18'd1537;
	  10'd46:
	    cinstruction = 18'd3585;
	  10'd47:
	    cinstruction = 18'd183830;
	  10'd48:
	    cinstruction = 18'd196768;
	  10'd49:
	    cinstruction = 18'd196659;
	  10'd50:
	    cinstruction = 18'd172032;
	  10'd51:
	    cinstruction = 18'd269;
	  10'd52:
	    cinstruction = 18'd196771;
	  10'd53:
	    cinstruction = 18'd266;
	  10'd54:
	    cinstruction = 18'd196771;
	  10'd55:
	    cinstruction = 18'd335;
	  10'd56:
	    cinstruction = 18'd196771;
	  10'd57:
	    cinstruction = 18'd331;
	  10'd58:
	    cinstruction = 18'd196771;
	  10'd59:
	    cinstruction = 18'd288;
	  10'd60:
	    cinstruction = 18'd196771;
	  10'd61:
	    cinstruction = 18'd320;
	  10'd62:
	    cinstruction = 18'd196771;
	  10'd63:
	    cinstruction = 18'd288;
	  10'd64:
	    cinstruction = 18'd196771;
	  10'd65:
	    cinstruction = 18'd3623;
	  10'd66:
	    cinstruction = 18'd20960;
	  10'd67:
	    cinstruction = 18'd196771;
	  10'd68:
	    cinstruction = 18'd118273;
	  10'd69:
	    cinstruction = 18'd85535;
	  10'd70:
	    cinstruction = 18'd218178;
	  10'd71:
	    cinstruction = 18'd269;
	  10'd72:
	    cinstruction = 18'd196771;
	  10'd73:
	    cinstruction = 18'd266;
	  10'd74:
	    cinstruction = 18'd196771;
	  10'd75:
	    cinstruction = 18'd172032;
	  10'd76:
	    cinstruction = 18'd269;
	  10'd77:
	    cinstruction = 18'd196771;
	  10'd78:
	    cinstruction = 18'd266;
	  10'd79:
	    cinstruction = 18'd196771;
	  10'd80:
	    cinstruction = 18'd335;
	  10'd81:
	    cinstruction = 18'd196771;
	  10'd82:
	    cinstruction = 18'd331;
	  10'd83:
	    cinstruction = 18'd196771;
	  10'd84:
	    cinstruction = 18'd288;
	  10'd85:
	    cinstruction = 18'd196771;
	  10'd86:
	    cinstruction = 18'd320;
	  10'd87:
	    cinstruction = 18'd196771;
	  10'd88:
	    cinstruction = 18'd288;
	  10'd89:
	    cinstruction = 18'd196771;
	  10'd90:
	    cinstruction = 18'd269;
	  10'd91:
	    cinstruction = 18'd196771;
	  10'd92:
	    cinstruction = 18'd266;
	  10'd93:
	    cinstruction = 18'd196771;
	  10'd94:
	    cinstruction = 18'd172032;
	  10'd95:
	    cinstruction = 18'd32192;
	  10'd96:
	    cinstruction = 18'd118064;
	  10'd97:
	    cinstruction = 18'd85258;
	  10'd98:
	    cinstruction = 18'd219239;
	  10'd99:
	    cinstruction = 18'd118023;
	  10'd100:
	    cinstruction = 18'd85264;
	  10'd101:
	    cinstruction = 18'd219239;
	  10'd102:
	    cinstruction = 18'd118048;
	  10'd103:
	    cinstruction = 18'd101377;
	  10'd104:
	    cinstruction = 18'd31680;
	  10'd105:
	    cinstruction = 18'd117552;
	  10'd106:
	    cinstruction = 18'd84746;
	  10'd107:
	    cinstruction = 18'd219248;
	  10'd108:
	    cinstruction = 18'd117511;
	  10'd109:
	    cinstruction = 18'd84752;
	  10'd110:
	    cinstruction = 18'd219248;
	  10'd111:
	    cinstruction = 18'd117536;
	  10'd112:
	    cinstruction = 18'd101377;
	  10'd113:
	    cinstruction = 18'd133894;
	  10'd114:
	    cinstruction = 18'd133894;
	  10'd115:
	    cinstruction = 18'd133894;
	  10'd116:
	    cinstruction = 18'd133894;
	  10'd117:
	    cinstruction = 18'd105424;
	  10'd118:
	    cinstruction = 18'd172032;
	  10'd119:
	    cinstruction = 18'd2563;
	  10'd120:
	    cinstruction = 18'd83713;
	  10'd121:
	    cinstruction = 18'd218232;
	  10'd122:
	    cinstruction = 18'd82208;
	  10'd123:
	    cinstruction = 18'd218232;
	  10'd124:
	    cinstruction = 18'd1792;
	  10'd125:
	    cinstruction = 18'd83713;
	  10'd126:
	    cinstruction = 18'd218237;
	  10'd127:
	    cinstruction = 18'd1792;
	  10'd128:
	    cinstruction = 18'd192928;
	  10'd129:
	    cinstruction = 18'd84480;
	  10'd130:
	    cinstruction = 18'd217221;
	  10'd131:
	    cinstruction = 18'd117249;
	  10'd132:
	    cinstruction = 18'd213117;
	  10'd133:
	    cinstruction = 18'd3072;
	  10'd134:
	    cinstruction = 18'd196703;
	  10'd135:
	    cinstruction = 18'd183056;
	  10'd136:
	    cinstruction = 18'd196703;
	  10'd137:
	    cinstruction = 18'd183057;
	  10'd138:
	    cinstruction = 18'd83713;
	  10'd139:
	    cinstruction = 18'd218250;
	  10'd140:
	    cinstruction = 18'd1792;
	  10'd141:
	    cinstruction = 18'd82208;
	  10'd142:
	    cinstruction = 18'd218250;
	  10'd143:
	    cinstruction = 18'd2592;
	  10'd144:
	    cinstruction = 18'd83713;
	  10'd145:
	    cinstruction = 18'd218256;
	  10'd146:
	    cinstruction = 18'd1792;
	  10'd147:
	    cinstruction = 18'd184736;
	  10'd148:
	    cinstruction = 18'd100865;
	  10'd149:
	    cinstruction = 18'd84520;
	  10'd150:
	    cinstruction = 18'd218256;
	  10'd151:
	    cinstruction = 18'd1537;
	  10'd152:
	    cinstruction = 18'd3586;
	  10'd153:
	    cinstruction = 18'd183830;
	  10'd154:
	    cinstruction = 18'd196768;
	  10'd155:
	    cinstruction = 18'd196684;
	  10'd156:
	    cinstruction = 18'd172032;
	  10'd157:
	    cinstruction = 18'd196771;
	  10'd158:
	    cinstruction = 18'd196768;
	  10'd159:
	    cinstruction = 18'd172032;
	  10'd160:
	    cinstruction = 18'd83457;
	  10'd161:
	    cinstruction = 18'd217248;
	  10'd162:
	    cinstruction = 18'd172032;
	  10'd163:
	    cinstruction = 18'd180480;
	  10'd164:
	    cinstruction = 18'd16384;
	  10'd165:
	    cinstruction = 18'd40961;
	  10'd166:
	    cinstruction = 18'd217252;
	  10'd167:
	    cinstruction = 18'd172032;
	  10'd168:
	    cinstruction = 18'd1;
	  10'd169:
	    cinstruction = 18'd180240;
	  10'd170:
	    cinstruction = 18'd16;
	  10'd171:
	    cinstruction = 18'd180241;
	  10'd172:
	    cinstruction = 18'd1537;
	  10'd173:
	    cinstruction = 18'd180501;
	  10'd174:
	    cinstruction = 18'd2;
	  10'd175:
	    cinstruction = 18'd180246;
	  10'd176:
	    cinstruction = 18'd1792;
	  10'd177:
	    cinstruction = 18'd196768;
	  10'd178:
	    cinstruction = 18'd172032;
	  10'd179:
	    cinstruction = 18'd1281;
	  10'd180:
	    cinstruction = 18'd17409;
	  10'd181:
	    cinstruction = 18'd41985;
	  10'd182:
	    cinstruction = 18'd218302;
	  10'd183:
	    cinstruction = 18'd1536;
	  10'd184:
	    cinstruction = 18'd1028;
	  10'd185:
	    cinstruction = 18'd181270;
	  10'd186:
	    cinstruction = 18'd229377;
	  10'd187:
	    cinstruction = 18'd266;
	  10'd188:
	    cinstruction = 18'd196771;
	  10'd189:
	    cinstruction = 18'd172032;
	  10'd190:
	    cinstruction = 18'd16642;
	  10'd191:
	    cinstruction = 18'd1025;
	  10'd192:
	    cinstruction = 18'd181251;
	  10'd193:
	    cinstruction = 18'd196771;
	  10'd194:
	    cinstruction = 18'd82189;
	  10'd195:
	    cinstruction = 18'd200891;
	  10'd196:
	    cinstruction = 18'd1793;
	  10'd197:
	    cinstruction = 18'd229377;
	  10'd1023:
	    cinstruction = 18'd213171;
	  default:
	    cinstruction = 18'd0;
	endcase
     end
endmodule
