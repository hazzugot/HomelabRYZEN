# 01 - Hardware Assembly

## Goal

This guide details the physical assembly of all server components into the custom 3D printed 10-inch rack-mount chassis.

## Tools Used

*   Electric screwdriver
*   Interchangeable screwdriver
*   Soldering iron (for melting in brass inserts)
*   3D printer
*   Calipers
*   Ruler
*   Sketch pad
*   Mechanical pencil

## Assembly Steps

### Step 0: Planning & Printing

It is important to plan the layout of your server before you start building. A quick sketch can help you visualize where each component will go and ensure that you have enough space for everything.

<img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/d051b68f-3f4d-4a3e-a4c3-7bc131358213" />


1.  **Print all the pieces for the chassis.**

    <img width="833" height="790" alt="image" src="https://github.com/user-attachments/assets/c757a844-85e9-42b0-954a-d9c65581617c" />


### Step 1: Brass Inserts

1.  **Install the brass inserts.** This is a crucial step to ensure that all components can be securely mounted. Use a soldering iron to carefully heat and press the brass inserts into the posts, braces, ITX mount, and NAS case.

    *   **ITX Mount:** Uses M3 x 5.7 mm brass inserts and M3 x 6mm bolts.
    *   **NAS Case:** Uses M6 Brass Inserts (8mm OD, 4mm Length) and M6 x 10mm screws.

    <img width="1073" height="623" alt="image" src="https://github.com/user-attachments/assets/2dfd5339-2f7a-4d28-a52f-c9d7d5600a2b" />

    <img width="650" height="721" alt="image" src="https://github.com/user-attachments/assets/a44cd1af-094a-4e6f-b912-c7b0a2ae06cf" />

    <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/706d5393-a01f-4c13-b62e-912e157f6a27" />


### Step 2: Main Chassis Assembly

1.  **Attach the fan to the top of the case.** This should be configured to exhaust hot air out of the top of the chassis to ensure good airflow.

    <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/256be140-ee33-4db6-b9f0-e95a006e664a" />


2.  **Assemble the bottom of the chassis.** Screw the frame together and add the feet.

    <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/430c51d0-1351-4104-859f-bf5811445257" />


3.  **Connect the long joints together.**

    <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/18b0303c-de1b-4cc5-8996-09c50ac34745" />


4.  **Attach the posts to the bottom of the case.**

    <img width="851" height="905" alt="image" src="https://github.com/user-attachments/assets/5a28349d-1074-450c-a0d1-23ddb15cbbfe" />


### Step 3: Component Installation

1.  **Assemble the motherboard.** Install the CPU, RAM, and CPU cooler onto the motherboard.

    <img width="889" height="806" alt="image" src="https://github.com/user-attachments/assets/c062676d-b158-40f2-a129-6b7b60cc41ad" />
<img width="961" height="515" alt="image" src="https://github.com/user-attachments/assets/91fce541-7777-4440-9643-bd9d6af3f532" />


2.  **Attach the motherboard to the ITX mount.** Also, install any PCIE expansion cards at this time.

    <img width="1045" height="724" alt="image" src="https://github.com/user-attachments/assets/bcf28ea4-dbc1-4ba1-b42c-3fb0e7d1de16" />


3.  **Perform an initial boot test (POST).** Connect the PSU to the essential components (motherboard, CPU, one stick of RAM) and ensure the system boots into the BIOS.

    <img width="697" height="455" alt="image" src="https://github.com/user-attachments/assets/8bb62235-3f60-43bc-82e3-6b38636319ec" />


4.  **Insert the PSU into its bracket.**

    <img width="785" height="886" alt="image" src="https://github.com/user-attachments/assets/e9e42165-300b-4c24-a60c-8ceec99dfc4f" />


5.  **Assemble the NAS.** Assemble the NAS frame, connect the quick-swap cables, and fit the drives into the drive mounts.

    <img width="900" height="943" alt="image" src="https://github.com/user-attachments/assets/8abc326c-b4b0-4af1-bda7-9c0fcf812888" />


### Step 4: Final Assembly

1.  **Start filling in the trays.** Install the ITX tray, NAS tray, and any other trays into the chassis. Rearrange if needed.
    > **Tip:** For heavy trays, print brackets long enough to reach both sides so they can be screwed in at the back for extra support.

    <img width="930" height="1155" alt="image" src="https://github.com/user-attachments/assets/b94f9da8-dc24-49f7-9c5f-88fa8a4a0e9a" />


2.  **Connect all the cables.** Connect the power cables for the NAS and PC, as well as any other components that need power or data.

    *Photo Placeholder: Show some of the cable connections.*

3.  **Attach the top panel.** Once all components are installed and connected, attach the top panel to complete the assembly.

    *Photo Placeholder: Show the finished, fully assembled server.*

## Conclusion

The assembly is complete. However, some parts were not printed to an amazing standard due to incorrect temperature settings or poor-quality filament. I plan to reprint these parts to improve the overall build quality. This is also noted in the troubleshooting log.

## References

*   **Mini ITX 10inch mount and ATX PSU mount:** [https://makerworld.com/en/models/1360827-2he-10-inch-rack-mount-mini-itx-atx-psu#profileId-1405438](https://makerworld.com/en/models/1360827-2he-10-inch-rack-mount-mini-itx-atx-psu#profileId-1405438)
*   **Main 5u Chasis and NAS tray design:** [https://makerworld.com/en/models/1294480-lab-rax-10-server-rack-5u#profileId-1325352](https://makerworld.com/en/models/1294480-lab-rax-10-server-rack-5u#profileId-1325352)
*   **Extension parts:** [https://makerworld.com/en/models/1294478-lab-rax-1-5u-posts-panels#profileId-1325351](https://makerworld.com/en/models/1294478-lab-rax-1-5u-posts-panels#profileId-1325351)
*   **Connecters for 3U extension:** [https://makerworld.com/en/models/1839684-lab-rax-sturdy-long-post-joiner#profileId-1965185](https://makerworld.com/en/models/1839684-lab-rax-sturdy-long-post-joiner#profileId-1965185)
*   **8u Skadis side panel print for multi-use:** [https://makerworld.com/en/models/1718939-lab-rax-8u-skadis-side-panels](https://makerworld.com/en/models/1718939-lab-rax-8u-skadis-side-panels)
*   **Switch holder:** [https://makerworld.com/en/models/1495240-pi-3b-4b-5b-tp-link-sg105-mx-sw-10-rack-mount#profileId-1577663](https://makerworld.com/en/models/1495240-pi-3b-4b-5b-tp-link-sg105-mx-sw-10-rack-mount#profileId-1577663)
