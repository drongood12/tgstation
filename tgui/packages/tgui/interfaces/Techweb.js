import { Button, Section, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible } from '../components';
import { Experiment } from './ExperimentConfigure';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Fragment } from 'inferno';
import { sortBy } from 'common/collections';

export const Techweb = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
    experiments,
    points,
    points_last_tick,
    web_org,
    sec_protocols,
    t_disk,
    d_disk,
  } = data;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  return (
    <Window
      width={640}
      height={880}
      title={`${web_org} Research and Development Network`}>
      <Window.Content>
        <Flex direction="column" className="Techweb__Viewport" height="100%">
          <Flex.Item className="Techweb__HeaderSection">
            <Flex direction="column" className="Techweb__HeaderContent">
              <Flex.Item>
                Available points:
                <ul className="Techweb__PointSummary">
                  {Object.keys(points).map(k => (
                    <li key={`ps${k}`}>
                      <b>{k}</b>: {points[k]} (+{points_last_tick[k] || 0}/t)
                    </li>
                  ))}
                </ul>
              </Flex.Item>
              <Flex.Item>
                Security protocols:
                <span
                  className={`Techweb__SecProtocol ${!!sec_protocols && "engaged"}`}>
                  {sec_protocols ? "Engaged" : "Disengaged"}
                </span>
              </Flex.Item>
              {(d_disk || t_disk) && (
                <Flex.Item>
                  {d_disk && (
                    <Button
                      onClick={() => setTechwebRoute({ route: "disk", diskType: "design" })}>
                      Design Disk Inserted
                    </Button>
                  )}
                  {t_disk && (
                    <Button
                      onClick={() => setTechwebRoute({ route: "disk", diskType: "tech" })}>
                      Tech Disk Inserted
                    </Button>
                  )}
                </Flex.Item>
              )}
            </Flex>
          </Flex.Item>
          <Flex.Item className="Techweb__RouterContent" height="100%">
            <TechwebRouter />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const TechwebRouter = (props, context) => {
  const [
    techwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  const route = techwebRoute?.route;
  const RoutedComponent = (
    route === "details" && TechwebNodeDetail
    || route === "disk" && TechwebDiskMenu
    || TechwebOverview
  );

  return (
    <RoutedComponent {...techwebRoute} />
  );
};

const TechwebOverview = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'overviewTabIndex', 1);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText');

  let displayedNodes = tabIndex < 2
    ? nodes.filter(x => x.tier === tabIndex)
    : nodes.filter(x => x.tier >= tabIndex);
  displayedNodes.sort((a, b) => {
    const an = node_cache[a.id];
    const bn = node_cache[b.id];
    return an.name.localeCompare(bn.name);
  });

  if (searchText && searchText.trim() !== '') {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText)
        || Object.keys(n.design_ids).some(e =>
          design_cache[e].name.toLowerCase().includes(searchText));
    });
  }

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            <span>Web View</span>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}>
                Researched
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}>
                Available
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}>
                Future
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align={"center"}>
            <Input
              value={searchText}
              onInput={(e, value) => setSearchText(value)}
              placeholder={"Search..."} />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className={"Techweb__OverviewNodes"} height="100%">
        {displayedNodes.map(n => {
          return (
            <TechNode node={n} key={`n${n.id}`} />
          );
        })}
      </Flex.Item>
    </Flex>
  );
};

const TechwebNodeDetail = (props, context) => {
  const { act, data } = useBackend(context);
  const { nodes } = data;
  const { selectedNode } = props;

  const selectedNodeData = selectedNode
    && nodes.filter(x => x.id === selectedNode)[0];
  return (
    <TechNodeDetail node={selectedNodeData} />
  );
};

const TechwebDiskMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { diskType } = props;
  const {
    t_disk,
    d_disk,
  } = data;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  // Check for the disk actually being inserted
  if ((diskType === "design" && !d_disk) || (diskType === "tech" && !t_disk)) {
    setTechwebRoute(null);
    return (<TechwebOverview />);
  }

  const DiskContent = diskType === "design" && TechwebDesignDisk
    || TechwebTechDisk;
  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {diskType.charAt(0).toUpperCase() + diskType.slice(1)} Disk
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab selected>
                Stored Data
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            {diskType === "tech" && (
              <Button
                icon="save"
                onClick={() => act("loadTech")}>
                Web &rarr; Disk
              </Button>
            )}
            <Button
              icon="upload"
              onClick={() => act("uploadDisk", { type: diskType })}>
              Disk &rarr; Web
            </Button>
            <Button
              icon="trash"
              onClick={() => act("eraseDisk", { type: diskType })}>
              Erase
            </Button>
            <Button
              icon="eject"
              onClick={() => act("ejectDisk", { type: diskType })}>
              Eject
            </Button>
            <Button
              icon="home"
              onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow={1} className="Techweb__OverviewNodes">
        <DiskContent />
      </Flex.Item>
    </Flex>
  );
};

const TechwebDesignDisk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    design_cache,
    researched_designs,
    d_disk,
  } = data;
  const {
    max_blueprints,
    blueprints,
  } = d_disk;
  const [
    selectedDesign,
    setSelectedDesign,
  ] = useLocalState(context, "designDiskSelect", null);
  const [
    showModal,
    setShowModal,
  ] = useLocalState(context, 'showDesignModal', -1);

  const designIdByIdx = Object.keys(researched_designs);
  let designOptions = designIdByIdx.reduce((prev, curr, idx) => {
    if (curr.toLowerCase() !== "error") {
      prev.push(`${design_cache[curr].name} [${idx}]`);
    }
    return prev;
  }, []).sort();

  return (
    <Fragment>
      {showModal >= 0 && (
        <Modal width="20em">
          <Flex direction="column" className="Techweb__DesignModal">
            <Flex.Item>
              Select a design to save...
            </Flex.Item>
            <Flex.Item>
              <Dropdown
                width="100%"
                options={designOptions}
                onSelected={val => {
                  const idx = parseInt(val.split('[').pop().split(']')[0], 10);
                  setSelectedDesign(designIdByIdx[idx]);
                }} />
            </Flex.Item>
            <Flex.Item align="center">
              <Button
                onClick={() => setShowModal(-1)}>
                Cancel
              </Button>
              <Button
                disabled={selectedDesign === null}
                onClick={() => {
                  act("writeDesign", {
                    slot: showModal + 1,
                    selectedDesign: selectedDesign,
                  });
                  setShowModal(-1);
                  setSelectedDesign(null);
                }}>
                Select
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}
      {blueprints.map((x, i) => {
        return (
          <Section
            title={`Slot ${i + 1}`}
            key={`slot-${i}`}
            buttons={
              <span>
                {x !== null && (
                  <Button
                    icon="upload"
                    onClick={() => act("uploadDesignSlot", { slot: i + 1 })}>
                    Upload Design to Web
                  </Button>
                )}
                <Button
                  icon="save"
                  onClick={() => setShowModal(i)}>
                  {x !== null ? "Overwrite Slot" : "Load Design to Slot"}
                </Button>
                {x !== null && (
                  <Button
                    icon="trash"
                    onClick={() => act("clearDesignSlot", { slot: i + 1 })}>
                    Clear Slot
                  </Button>
                )}
              </span>
            }>
            {x === null && (
              <span>Empty</span>
            ) || (
              <span>
                Contains the design for <b>{design_cache[x].name}</b>:<br />
                <span
                  className={`${design_cache[x].class} Techweb__DesignIcon`} />
              </span>
            )}
          </Section>
        );
      })}
    </Fragment>
  );
};

const TechwebTechDisk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    t_disk,
  } = data;
  const {
    stored_research,
  } = t_disk;

  const storedNodes = Object.keys(stored_research).reduce((arr, val) => {
    const foundNode = nodes.filter(x => x.id === val)[0];
    if (foundNode) {
      arr.push(foundNode);
    }
    return arr;
  }, []);

  return storedNodes.map(n => (
    <TechNode nocontrols node={n} key={`n-${n.id}`} />
  ));
};

const TechNodeDetail = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
    experiments,
    points,
  } = data;
  const { node } = props;
  const {
    id,
    can_unlock,
    tier,
  } = node;
  let thisNode = node_cache[id];
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'nodeDetailTabIndex', 0);
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);

  const prereqNodes = thisNode.prereq_ids.reduce((arr, val) => {
    const foundNode = nodes.filter(x => x.id === val)[0];
    if (foundNode)
    { arr.push(foundNode); }
    return arr;
  }, []);

  const unlockedNodes = Object.keys(thisNode.unlock_ids).reduce((arr, val) => {
    const foundNode = nodes.filter(x => x.id === val)[0];
    if (foundNode)
    { arr.push(foundNode); }
    return arr;
  }, []);

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}>
                Details
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                disabled={prereqNodes.length === 0}
                onClick={() => setTabIndex(1)}>
                Required ({prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(2)}>
                Unlocks ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button
              icon="home"
              onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes">
          <TechNode node={node} nodetails />
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes">
          {prereqNodes.map(n =>
            (<TechNode node={n} key={`nr${n.id}`} />)
          )}
        </Flex.Item>
      )}
      {tabIndex === 2 && (
        <Flex.Item className="Techweb__OverviewNodes">
          {unlockedNodes.map(n =>
            (<TechNode node={n} key={`nu${n.id}`} />)
          )}
        </Flex.Item>
      )}
    </Flex>
  );
};

const TechNode = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    node_cache,
    design_cache,
    experiments,
    points,
  } = data;
  const { node, nodetails, nocontrols } = props;
  const {
    id,
    can_unlock,
    tier,
  } = node;
  let thisNode = node_cache[id];
  let reqExp = thisNode?.required_experiments;
  const [
    techwebRoute,
    setTechwebRoute,
  ] = useLocalState(context, 'techwebRoute', null);
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'nodeDetailTabIndex', 0);
  const selected = false;

  const expcompl = reqExp.filter(x => experiments[x]?.completed).length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / reqExp.length}>
      Experiments ({expcompl}/{reqExp.length})
    </ProgressBar>
  );

  return (
    <Section title={thisNode.name}
      buttons={!nocontrols && (
        <span>
          {!nodetails && (
            <Button
              icon="tasks"
              onClick={() => {
                setTechwebRoute({ route: "details", selectedNode: node.id });
                setTabIndex(0);
              }}>
              Details
            </Button>
          )}
          {tier === 1 && (
            <Button
              icon="lightbulb"
              disabled={!can_unlock}
              onClick={() => act("researchNode", { node_id: thisNode.id })}>
              Research
            </Button>)}
        </span>
      )}
      level={1}
      className="Techweb__NodeContainer">
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {Object.keys(thisNode.costs).map((k, i) => {
            const nodeProg = Math.min(thisNode.costs[k], points[k]) || 0;
            return (
              <Flex.Item grow={1} basis={0}
                key={`n${thisNode.id}p${i}`}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={Math.min(1, points[k] / thisNode.costs[k])}>
                  {k} ({nodeProg}/{thisNode.costs[k]})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {reqExp?.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <div className="Techweb__NodeDescription">{thisNode.description}</div>
      <Box className="Techweb__NodeUnlockedDesigns">
        {Object.keys(thisNode.design_ids).map((k, i) => {
          return (
            <Button key={`d${thisNode.id}`}
              className={`${design_cache[k].class} Techweb__DesignIcon`}
              tooltip={design_cache[k].name}
              tooltipPosition={i % 15 < 7 ? "right" : "left"} />
          );
        })}
      </Box>
      {thisNode.required_experiments?.length > 0
        && (
          <Collapsible
            className="Techweb__NodeExperimentsRequired"
            title="Required Experiments">
            {thisNode.required_experiments.map(k => {
              const thisExp = experiments[k];
              if (thisExp === null || thisExp === undefined) {
                return (
                  <div>Failed to find experiment &apos;{k}&apos;</div>
                );
              }
              return (
                <Experiment key={`n${thisNode.id}e${thisExp}`} exp={thisExp} />
              );
            })}
          </Collapsible>
        )}
    </Section>
  );
};
