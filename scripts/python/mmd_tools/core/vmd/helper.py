from typing import List

class CameraInterpolation:
    def __init__(self, interp_data: List[int]):
        idx = 0
        xP1x = interp_data[idx];idx += 1
        xP2x = interp_data[idx];idx += 1
        xP1y = interp_data[idx];idx += 1
        xP2y = interp_data[idx];idx += 1

        yP1x = interp_data[idx];idx += 1
        yP2x = interp_data[idx];idx += 1
        yP1y = interp_data[idx];idx += 1
        yP2y = interp_data[idx];idx += 1

        zP1x = interp_data[idx];idx += 1
        zP2x = interp_data[idx];idx += 1
        zP1y = interp_data[idx];idx += 1
        zP2y = interp_data[idx];idx += 1

        rP1x = interp_data[idx];idx += 1
        rP2x = interp_data[idx];idx += 1
        rP1y = interp_data[idx];idx += 1
        rP2y = interp_data[idx];idx += 1

        dP1x = interp_data[idx];idx += 1
        dP2x = interp_data[idx];idx += 1
        dP1y = interp_data[idx];idx += 1
        dP2y = interp_data[idx];idx += 1

        pP1x = interp_data[idx];idx += 1
        pP2x = interp_data[idx];idx += 1
        pP1y = interp_data[idx];idx += 1
        pP2y = interp_data[idx];idx += 1

        self.interp_x = [xP1x, xP1y, xP2x, xP2y]
        self.interp_y = [yP1x, yP1y, yP2x, yP2y]
        self.interp_z = [zP1x, zP1y, zP2x, zP2y]
        self.interp_r = [rP1x, rP1y, rP2x, rP2y]
        self.interp_dist = [dP1x, dP1y, dP2x, dP2y]
        self.interp_fov = [pP1x, pP1y, pP2x, pP2y]