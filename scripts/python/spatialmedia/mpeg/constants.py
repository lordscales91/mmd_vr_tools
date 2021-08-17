#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""MPEG-4 constants."""

TRAK_TYPE_VIDE = b"vide"

# Leaf types.
TAG_STCO = b"stco"
TAG_CO64 = b"co64"
TAG_FREE = b"free"
TAG_MDAT = b"mdat"
TAG_XML = b"xml "
TAG_HDLR = b"hdlr"
TAG_FTYP = b"ftyp"
TAG_ESDS = b"esds"
TAG_SOUN = b"soun"
TAG_SA3D = b"SA3D"

# Container types.
TAG_MOOV = b"moov"
TAG_UDTA = b"udta"
TAG_META = b"meta"
TAG_TRAK = b"trak"
TAG_MDIA = b"mdia"
TAG_MINF = b"minf"
TAG_STBL = b"stbl"
TAG_STSD = b"stsd"
TAG_UUID = b"uuid"
TAG_WAVE = b"wave"

# Sound sample descriptions.
TAG_NONE = b"NONE"
TAG_RAW_ = b"raw "
TAG_TWOS = b"twos"
TAG_SOWT = b"sowt"
TAG_FL32 = b"fl32"
TAG_FL64 = b"fl64"
TAG_IN24 = b"in24"
TAG_IN32 = b"in32"
TAG_ULAW = b"ulaw"
TAG_ALAW = b"alaw"
TAG_LPCM = b"lpcm"
TAG_MP4A = b"mp4a"
TAG_OPUS = b"Opus"

# Video sample descriptions
TAG_AVC1 = b"avc1"

SOUND_SAMPLE_DESCRIPTIONS = frozenset([
    TAG_NONE,
    TAG_RAW_,
    TAG_TWOS,
    TAG_SOWT,
    TAG_FL32,
    TAG_FL64,
    TAG_IN24,
    TAG_IN32,
    TAG_ULAW,
    TAG_ALAW,
    TAG_LPCM,
    TAG_MP4A,
    TAG_OPUS,
    ])

CONTAINERS_LIST = frozenset([
    TAG_MDIA,
    TAG_MINF,
    TAG_MOOV,
    TAG_STBL,
    TAG_STSD,
    TAG_TRAK,
    TAG_UDTA,
    TAG_WAVE,
    TAG_AVC1,
    ]).union(SOUND_SAMPLE_DESCRIPTIONS)


SPHERICAL_UUID_ID = b"\xff\xcc\x82\x63\xf8\x55\x4a\x93\x88\x14\x58\x7a\x02\x52\x1f\xdd"

# XML contents.
RDF_PREFIX = " xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" "

SPHERICAL_XML_HEADER = \
    "<?xml version=\"1.0\"?>"\
    "<rdf:SphericalVideo\n"\
    "xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n"\
    "xmlns:GSpherical=\"http://ns.google.com/videos/1.0/spherical/\">"

SPHERICAL_XML_CONTENTS = \
    "<GSpherical:Spherical>true</GSpherical:Spherical>"\
    "<GSpherical:Stitched>true</GSpherical:Stitched>"\
    "<GSpherical:StitchingSoftware>"\
    "Spherical Metadata Tool"\
    "</GSpherical:StitchingSoftware>"\
    "<GSpherical:ProjectionType>equirectangular</GSpherical:ProjectionType>"

SPHERICAL_XML_CONTENTS_FORMAT = \
    "<GSpherical:Spherical>true</GSpherical:Spherical>"\
    "<GSpherical:Stitched>true</GSpherical:Stitched>"\
    "<GSpherical:StitchingSoftware>{0}</GSpherical:StitchingSoftware>"\
    "<GSpherical:ProjectionType>equirectangular</GSpherical:ProjectionType>"

SPHERICAL_XML_CONTENTS_TOP_BOTTOM = \
    "<GSpherical:StereoMode>top-bottom</GSpherical:StereoMode>"
SPHERICAL_XML_CONTENTS_LEFT_RIGHT = \
    "<GSpherical:StereoMode>left-right</GSpherical:StereoMode>"

SPHERICAL_XML_CONTENTS_CROP_FORMAT = \
    "<GSpherical:CroppedAreaImageWidthPixels>{0}"\
    "</GSpherical:CroppedAreaImageWidthPixels>"\
    "<GSpherical:CroppedAreaImageHeightPixels>{1}"\
    "</GSpherical:CroppedAreaImageHeightPixels>"\
    "<GSpherical:FullPanoWidthPixels>{2}</GSpherical:FullPanoWidthPixels>"\
    "<GSpherical:FullPanoHeightPixels>{3}</GSpherical:FullPanoHeightPixels>"\
    "<GSpherical:CroppedAreaLeftPixels>{4}</GSpherical:CroppedAreaLeftPixels>"\
    "<GSpherical:CroppedAreaTopPixels>{5}</GSpherical:CroppedAreaTopPixels>"

SPHERICAL_XML_FOOTER = "</rdf:SphericalVideo>"

