XSD_LICENSE_DATA =b"""<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- Custom type: [item1,item2,...] -->
  <xs:simpleType name="ArrayOfStrings">
    <xs:restriction base="xs:string">
      <!-- Matches [], [A], [A,B,C] -->
      <xs:pattern value="\[([A-Za-z0-9_:]+(,[A-Za-z0-9_:]+)*)?\]"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:element name="License">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Users">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="User0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="UserName" type="xs:string"/>
                    <xs:element name="Password" type="xs:string"/>
                    <xs:element name="Role" type="xs:string"/>

                    <!-- Array fields -->
                    <xs:element name="Right" type="ArrayOfStrings"/>
                    <xs:element name="ExcludeRightXml" type="ArrayOfStrings"/>
                    <xs:element name="DisableFeatureXml" type="ArrayOfStrings"/>

                    <xs:element name="Trial_Period_Start" type="xs:date"/>
                    <xs:element name="Trial_Period_END" type="xs:date"/>
                    <xs:element name="Enterprise" type="xs:string"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>

            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

</xs:schema>

"""