# -*- coding: utf-8 -*-
from typing import List, Union
import math

"""
This code has been ported from the MMDMotion library for Java: https://osdn.net/projects/mmdmotion-java/
"""

class Vector3D:

    def __init__(self, r: List[float] = None):
        self.r = [0.0, 0.0, 0.0]
        if r is not None:
            for i in range(3):
                self.r[i] = r[i]

    @staticmethod
    def fromXYZ(x: float, y: float, z:float) -> 'Vector3D':
        return Vector3D([x,y,z])
    
    def norm(self) -> float:
        return math.sqrt(self.norm2())

    def norm2(self) -> float:
        r = self.r
        return r[0]*r[0]+r[1]*r[1]+r[2]*r[2]

    def add(self, b: 'Vector3D') -> 'Vector3D':
        r = self.r
        return Vector3D.fromXYZ(r[0]+b.r[0],r[1]+b.r[1],r[2]+b.r[2])

    def sub(self, b: 'Vector3D') -> 'Vector3D':
        r = self.r
        return Vector3D.fromXYZ(r[0]-b.r[0],r[1]-b.r[1],r[2]-b.r[2])

    def inverse(self) -> 'Vector3D':
        r = self.r
        return Vector3D.fromXYZ(-r[0],-r[1],-r[2])
    
    def divide(self, d: float) -> 'Vector3D':
        r = self.r
        return Vector3D.fromXYZ(r[0]/d,r[1]/d,r[2]/d)
    
    def times(self, val: Union[float, 'Vector3D']) -> Union['Vector3D', float]:
        r = self.r
        if type(val) == 'float':
            m = val
            return Vector3D.fromXYZ(r[0]*m,r[1]*m,r[2]*m)
        else:
            b = val
            return r[0]*b.r[0]+r[1]*b.r[1]+r[2]*b.r[2]
    
    def cross(self, b: 'Vector3D') -> 'Vector3D':
        r = self.r
        return Vector3D.fromXYZ(
            r[1]*b.r[2]-r[2]*b.r[1],
            r[2]*b.r[0]-r[0]*b.r[2],
            r[0]*b.r[1]-r[1]*b.r[0])


class Matrix:

    def __init__(self, r:List[float] = None):
        self.r = [
                1.0, 0.0, 0.0, 
                0.0, 1.0, 0.0,
                0.0, 0.0, 1.0]
        if r is not None:
            for i in range(9):
                self.r[i] = r[i]
            
    @staticmethod
    def rotation(rx: float, ry: float, rz: float) -> 'Matrix':
        b,c,r = Matrix(), Matrix(), Matrix()

        a = [0.0] * 9
        a[0] = a[4] = math.cos(rz * math.pi/180)
        a[3] = math.sin(rz * math.pi/180)
        a[1]=-a[3]
        a[8]=1
        a[2]=a[5]=a[6]=a[7]=0
        c = Matrix(a)

        a[4]=a[8]=math.cos(rx*math.pi/180)
        a[5]=math.sin(rx*math.pi/180)
        a[7]=-a[5]
        a[0]=1
        a[1]=a[2]=a[3]=a[6]=0
        b = Matrix(a)
        r = b.times(c)

        a[0]=a[8]=math.cos(ry*math.pi/180)
        a[2]=math.sin(ry*math.pi/180)
        a[6]=-a[2]
        a[4]=1
        a[1]=a[3]=a[5]=a[7]=0
        c = Matrix(a)

        return c.times(r)

    @staticmethod
    def rotationQ(nx: float, ny: float, nz: float, w: float) -> 'Matrix':
        a = [0.0] * 9
        s = [0.0] * 10
        norm = math.sqrt(nx*nx + ny*ny + nz*nz + w*w)
        nx/=norm
        ny/=norm
        nz/=norm
        w/=norm

        s[0]=w*w;s[1]=nx*nx;s[2]=ny*ny;s[3]=nz*nz
        s[4]=w*nx;s[5]=w*ny;s[6]=w*nz
        s[7]=nx*ny;s[8]=nx*nz;s[9]=ny*nz

        a[0]=s[0]+s[1]-s[2]-s[3]
        a[4]=s[0]-s[1]+s[2]-s[3]
        a[8]=s[0]-s[1]-s[2]+s[3]

        a[1]=2*(s[7]+s[6])
        a[2]=2*(s[8]-s[5])

        a[3]=2*(s[7]-s[6])
        a[5]=2*(s[9]+s[4])

        a[6]=2*(s[8]+s[5])
        a[7]=2*(s[9]-s[4])

        return Matrix(a)

    def angles(self) -> List[float]:
        r = self.r
        tx,ty,tz,pz,x = Vector3D(), Vector3D(), Vector3D(), Vector3D(), Vector3D()
        rz = 0.0
        rv = [0.0] * 3

        pz = Vector3D.fromXYZ(r[6], 0, r[8])
        rz = pz.norm()
        rv[0]=math.atan2(-r[7], rz)
        rv[1]= 0 if (r[7]<=-1 or r[7]>=1) else math.atan2(-r[6],r[8])

        tz=pz.divide(rz)
        tx=tz.cross(Vector3D.fromXYZ(0,1,0))
        ty=Vector3D.fromXYZ(r[6],r[7],r[8]).cross(tx)
        x=Vector3D.fromXYZ(r[0],r[1],r[2])
        rv[2]=math.atan2(x.times(ty),-x.times(tx))

        for i in range(3):
            rv[i]*=180/math.pi

        return rv
    
    def quaternions(self) -> List[float]:
        r = self.r
        q = [0.0] * 4
        q[3]= r[0]+r[4]+r[8]+1
        q[0]= r[0]-r[4]-r[8]+1
        q[1]=-r[0]+r[4]-r[8]+1
        q[2]=-r[0]-r[4]+r[8]+1

        max_val = max(q)
        biggest = q.index(max_val)
        q[biggest] = math.sqrt(max_val) * 0.5

        mult = 0.25 / q[biggest]
        if(biggest==0): 
            q[1]=(r[1]+r[3])*mult
            q[2]=(r[2]+r[6])*mult
            q[3]=(r[5]-r[7])*mult
        elif(biggest==1):
            q[0]=(r[1]+r[3])*mult
            q[2]=(r[5]+r[7])*mult
            q[3]=(r[6]-r[2])*mult
        elif(biggest==2):
            q[0]=(r[2]+r[6])*mult
            q[1]=(r[5]+r[7])*mult
            q[3]=(r[1]-r[3])*mult            
        else:
            q[0]=(r[5]-r[7])*mult
            q[1]=(r[6]-r[2])*mult
            q[2]=(r[1]-r[3])*mult

        return q


    def times(self, b:'Matrix') -> 'Matrix':
        r = self.r
        ret = Matrix()
        for i in range(0, 9, 3):
            for j in range(3):
                ret.r[i+j] = r[j]*b.r[i] + r[j+3]*b.r[i+1] + r[j+6]*b.r[i+2]
        return ret
            